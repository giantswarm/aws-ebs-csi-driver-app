package basic

import (
	"fmt"
	"testing"
	"time"

	"e2e/internal/testhelpers"

	"github.com/giantswarm/apptest-framework/v2/pkg/state"
	"github.com/giantswarm/apptest-framework/v2/pkg/suite"
	"github.com/giantswarm/clustertest/v2/pkg/failurehandler"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
)

const (
	isUpgrade     = false
	testNamespace = "default"
	pvcName       = "ebs-claim-e2e"
	writerPodName = "ebs-writer-e2e"
	readerPodName = "ebs-reader-e2e"
	scName        = "gp3"
	testData      = "ebs-dynamic-provisioning-works"
)

func TestBasic(t *testing.T) {
	suite.New().
		WithInCluster(true).
		WithInstallNamespace("").
		WithIsUpgrade(isUpgrade).
		WithValuesFile("./values.yaml").
		Tests(func() {
			It("should have the HelmRelease ready on the management cluster", func() {
				mcClient := state.GetFramework().MC()
				clusterName := state.GetCluster().Name
				orgName := state.GetCluster().Organization.Name

				Eventually(func() (bool, error) {
					ready, err := testhelpers.HelmReleaseIsReady(*mcClient, clusterName, orgName)
					if err != nil {
						GinkgoLogr.Info("HelmRelease check failed", "error", err.Error())
					} else if !ready {
						GinkgoLogr.Info("HelmRelease not ready yet", "name", clusterName+"-aws-ebs-csi-driver")
					} else {
						GinkgoLogr.Info("HelmRelease is ready", "name", clusterName+"-aws-ebs-csi-driver")
					}
					return ready, err
				}).
					WithTimeout(15 * time.Minute).
					WithPolling(10 * time.Second).
					Should(BeTrue(), failurehandler.LLMPrompt(state.GetFramework(), state.GetCluster(), "Investigate HelmRelease not ready for aws-ebs-csi-driver"))
			})

			It("should have the ebs-csi-controller deployment running", func() {
				wcClient, err := state.GetFramework().WC(state.GetCluster().Name)
				Expect(err).Should(Succeed())

				Eventually(func() error {
					var dp appsv1.Deployment
					err := wcClient.Get(state.GetContext(), types.NamespacedName{
						Namespace: "kube-system",
						Name:      "ebs-csi-controller",
					}, &dp)
					if err != nil {
						GinkgoLogr.Info("ebs-csi-controller not found yet", "error", err.Error())
					} else {
						GinkgoLogr.Info("ebs-csi-controller found",
							"replicas", dp.Status.Replicas,
							"ready", dp.Status.ReadyReplicas,
							"available", dp.Status.AvailableReplicas,
						)
					}
					return err
				}).
					WithTimeout(10 * time.Minute).
					WithPolling(5 * time.Second).
					ShouldNot(HaveOccurred(), failurehandler.LLMPrompt(state.GetFramework(), state.GetCluster(), "Investigate ebs-csi-controller deployment not found or not running"))
			})

			It("should have the ebs-csi-node daemonset running", func() {
				wcClient, err := state.GetFramework().WC(state.GetCluster().Name)
				Expect(err).Should(Succeed())

				Eventually(func() error {
					var ds appsv1.DaemonSet
					err := wcClient.Get(state.GetContext(), types.NamespacedName{
						Namespace: "kube-system",
						Name:      "ebs-csi-node",
					}, &ds)
					if err != nil {
						GinkgoLogr.Info("ebs-csi-node not found yet", "error", err.Error())
					} else {
						GinkgoLogr.Info("ebs-csi-node found",
							"desired", ds.Status.DesiredNumberScheduled,
							"ready", ds.Status.NumberReady,
						)
					}
					return err
				}).
					WithTimeout(10 * time.Minute).
					WithPolling(5 * time.Second).
					ShouldNot(HaveOccurred(), failurehandler.LLMPrompt(state.GetFramework(), state.GetCluster(), "Investigate ebs-csi-node daemonset not found or not running"))
			})

			It("should dynamically provision an EBS volume and allow read-write access", func() {
				wcClient, err := state.GetFramework().WC(state.GetCluster().Name)
				Expect(err).Should(Succeed())
				ctx := state.GetContext()

				By("Creating a PVC using the gp3 StorageClass")
				pvc := &corev1.PersistentVolumeClaim{
					ObjectMeta: metav1.ObjectMeta{
						Name:      pvcName,
						Namespace: testNamespace,
					},
					Spec: corev1.PersistentVolumeClaimSpec{
						AccessModes:      []corev1.PersistentVolumeAccessMode{corev1.ReadWriteOnce},
						StorageClassName: ptr(scName),
						Resources: corev1.VolumeResourceRequirements{
							Requests: corev1.ResourceList{
								corev1.ResourceStorage: resource.MustParse("1Gi"),
							},
						},
					},
				}
				Expect(wcClient.Create(ctx, pvc)).To(Succeed())

				By("Creating a writer Pod that mounts the EBS volume and writes data")
				writerPod := newTestPod(writerPodName, testNamespace, pvcName,
					[]string{"sh", "-c", fmt.Sprintf("echo '%s' > /data/testfile && echo 'write-ok'", testData)},
				)
				Expect(wcClient.Create(ctx, writerPod)).To(Succeed())

				By("Waiting for the writer Pod to succeed")
				Eventually(func() (corev1.PodPhase, error) {
					var pod corev1.Pod
					err := wcClient.Get(ctx, types.NamespacedName{
						Name:      writerPodName,
						Namespace: testNamespace,
					}, &pod)
					if err != nil {
						GinkgoLogr.Info("writer pod not found yet", "error", err.Error())
						return "", err
					}
					GinkgoLogr.Info("writer pod status", "phase", pod.Status.Phase)
					return pod.Status.Phase, nil
				}).
					WithTimeout(10 * time.Minute).
					WithPolling(5 * time.Second).
					Should(Equal(corev1.PodSucceeded), failurehandler.LLMPrompt(state.GetFramework(), state.GetCluster(), "Investigate EBS writer pod not succeeding"))

				By("Verifying the PVC is bound")
				var claim corev1.PersistentVolumeClaim
				Expect(wcClient.Get(ctx, types.NamespacedName{
					Name:      pvcName,
					Namespace: testNamespace,
				}, &claim)).To(Succeed())
				Expect(claim.Status.Phase).To(Equal(corev1.ClaimBound))

				By("Deleting the writer pod before creating reader (EBS is ReadWriteOnce)")
				writerPodObj := &corev1.Pod{
					ObjectMeta: metav1.ObjectMeta{Name: writerPodName, Namespace: testNamespace},
				}
				Expect(client.IgnoreNotFound(wcClient.Delete(ctx, writerPodObj))).To(Succeed())

				By("Waiting for writer pod to be deleted")
				Eventually(func() bool {
					err := wcClient.Get(ctx, types.NamespacedName{
						Name:      writerPodName,
						Namespace: testNamespace,
					}, &corev1.Pod{})
					return apierrors.IsNotFound(err)
				}).WithTimeout(2 * time.Minute).WithPolling(5 * time.Second).Should(BeTrue())

				By("Creating a reader Pod that reads data from the same EBS volume")
				readerPod := newTestPod(readerPodName, testNamespace, pvcName,
					[]string{"sh", "-c", fmt.Sprintf("cat /data/testfile | grep '%s'", testData)},
				)
				Expect(wcClient.Create(ctx, readerPod)).To(Succeed())

				By("Waiting for the reader Pod to succeed")
				Eventually(func() (corev1.PodPhase, error) {
					var pod corev1.Pod
					err := wcClient.Get(ctx, types.NamespacedName{
						Name:      readerPodName,
						Namespace: testNamespace,
					}, &pod)
					if err != nil {
						GinkgoLogr.Info("reader pod not found yet", "error", err.Error())
						return "", err
					}
					GinkgoLogr.Info("reader pod status", "phase", pod.Status.Phase)
					return pod.Status.Phase, nil
				}).
					WithTimeout(5 * time.Minute).
					WithPolling(5 * time.Second).
					Should(Equal(corev1.PodSucceeded), failurehandler.LLMPrompt(state.GetFramework(), state.GetCluster(), "Investigate EBS reader pod not succeeding"))
			})
		}).
		AfterSuite(func() {
			ctx := state.GetContext()
			wcClient, err := state.GetFramework().WC(state.GetCluster().Name)
			if err == nil {
				for _, name := range []string{readerPodName, writerPodName} {
					pod := &corev1.Pod{
						ObjectMeta: metav1.ObjectMeta{Name: name, Namespace: testNamespace},
					}
					_ = client.IgnoreNotFound(wcClient.Delete(ctx, pod))
				}
				pvc := &corev1.PersistentVolumeClaim{
					ObjectMeta: metav1.ObjectMeta{Name: pvcName, Namespace: testNamespace},
				}
				_ = client.IgnoreNotFound(wcClient.Delete(ctx, pvc))
			}
		}).
		Run(t, "EBS Dynamic Provisioning")
}

func newTestPod(name, namespace, pvcName string, command []string) *corev1.Pod {
	return &corev1.Pod{
		ObjectMeta: metav1.ObjectMeta{
			Name:      name,
			Namespace: namespace,
		},
		Spec: corev1.PodSpec{
			RestartPolicy: corev1.RestartPolicyNever,
			SecurityContext: &corev1.PodSecurityContext{
				RunAsNonRoot: ptr(true),
				RunAsUser:    ptr(int64(1000)),
				RunAsGroup:   ptr(int64(1000)),
				FSGroup:      ptr(int64(1000)),
				SeccompProfile: &corev1.SeccompProfile{
					Type: corev1.SeccompProfileTypeRuntimeDefault,
				},
			},
			Containers: []corev1.Container{
				{
					Name:    "test",
					Image:   "busybox:1.36",
					Command: command,
					SecurityContext: &corev1.SecurityContext{
						AllowPrivilegeEscalation: ptr(false),
						Capabilities: &corev1.Capabilities{
							Drop: []corev1.Capability{"ALL"},
						},
					},
					VolumeMounts: []corev1.VolumeMount{
						{
							Name:      "data-volume",
							MountPath: "/data",
						},
					},
				},
			},
			Volumes: []corev1.Volume{
				{
					Name: "data-volume",
					VolumeSource: corev1.VolumeSource{
						PersistentVolumeClaim: &corev1.PersistentVolumeClaimVolumeSource{
							ClaimName: pvcName,
						},
					},
				},
			},
		},
	}
}

func ptr[T any](v T) *T { return &v }
