### Intro

Many iffy opinions about how CPU requests & limits in Kubernetes work circulate the Internet.
For example, some people believe that if a pod requests 300mCPU, it is guaranteed to have the 300mCPU available during runtime.
This project is a simple experiment aimed at disproving that.

### Experiment methodology

- A `minikube` cluster with 1 CPU is spawned.
- We create two simultaneous containers, both designed to try to eat 100% CPU, to compete with each other for CPU.
- The containers are deployed throughout several scenarios in various combinations of CPU requests/limits.
- At the end of each scenario, the CPU usage of both pods is examined and compared.

The entire experiment is automated within `run.sh`. Simply run it, wait, and observe the results.

Requirements:
- `bash`
- `minikube`
- `kubectl`

### Expected results & commentary

```
-----Initiating test scenarios-----
-----Scenario 1-----
deployment.apps/no-request-no-limit-1 created
deployment.apps/no-request-no-limit-2 created
NAME                                     CPU(cores)   MEMORY(bytes)   
no-request-no-limit-1-769c86549d-v5rnl   364m         1Mi             
no-request-no-limit-2-79cbf77884-w69rf   393m         1Mi             
deployment.apps "no-request-no-limit-1" deleted
deployment.apps "no-request-no-limit-2" deleted
-----Scenario 2-----
deployment.apps/750-request-no-limit-1 created
deployment.apps/no-request-no-limit-2 created
NAME                                      CPU(cores)   MEMORY(bytes)   
750-request-no-limit-1-86c5947c45-hpwxl   405m         1Mi             
no-request-no-limit-2-79cbf77884-szncj    295m         1Mi             
deployment.apps "750-request-no-limit-1" deleted
deployment.apps "no-request-no-limit-2" deleted
-----Scenario 3-----
deployment.apps/750-request-no-limit-1 created
deployment.apps/100-request-no-limit-2 created
NAME                                      CPU(cores)   MEMORY(bytes)   
100-request-no-limit-2-5575b7cdf9-ncd4g   307m         1Mi             
750-request-no-limit-1-86c5947c45-8jrww   365m         1Mi             
deployment.apps "750-request-no-limit-1" deleted
deployment.apps "100-request-no-limit-2" deleted
-----Scenario 4-----
deployment.apps/750-request-no-limit-1 created
deployment.apps/100-request-100-limit-2 created
NAME                                       CPU(cores)   MEMORY(bytes)   
100-request-100-limit-2-7cf7bfd956-x5qlp   100m         1Mi             
750-request-no-limit-1-86c5947c45-tkxvn    780m         1Mi             
deployment.apps "750-request-no-limit-1" deleted
deployment.apps "100-request-100-limit-2" deleted
-----Scenario 5-----
deployment.apps/750-request-750-limit-1 created
deployment.apps/100-request-100-limit-2 created
NAME                                       CPU(cores)   MEMORY(bytes)   
100-request-100-limit-2-7cf7bfd956-2v2hz   100m         1Mi             
750-request-750-limit-1-8b94b7d8b-l7vg6    733m         1Mi             
deployment.apps "750-request-750-limit-1" deleted
deployment.apps "100-request-100-limit-2" deleted
```

- Scenario 1 results imply that with no CPU requests/limits in place, both pods get approximately the same amount of CPU
- Scenario 2 results imply that both pods get approximately the same amount of CPU, despite one requesting more
- Scenario 3 results imply that both pods get approximately the same amount of CPU, despite one requesting more, and the other requesting less
- Scenario 4 results imply that limiting the CPU usage of the pod with the lower request ensures that the pod with the higher request gets what it requested

