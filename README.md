# RNDRkiller
Shutdown and restart the RNDR client based on CPU and GPU Activity.

### About:
This PowerShell script will poll CPU activity and GPU activity (from nvidia-smi) and restart `rndrclient.exe` if both CPU and GPU activity are under a preset threshold.

### Config:

- `$appToLaunch` Replace this string with the full path to your render client.
- `$cpuThreshold` This is the CPU activity threshold variable
- `$gpuThreshold` This is the GPU activity threshold variable
- `$checkInterval` This is the duration we will wait before attempting again after the threshold values are not met.
- `$postCloseDelay` This is how long we will wait after kill RNDR before relaunching it.
- `$nvidiaSmiPath` You shouldn't have to change this. If you have installed any NVIDIA drivers, this path already exists.

### Suggested Usage:
In Task Scheduler, set up a daily scheduled task for the early AM to launch the `RNDRkiller.bat`. It should poll for CPU and GPU usage and restart the client if it finds both under the threshold. It will then close after a successful run. If it finds CPU or GPU activity above the threshold, it will pause for 5 minutes (by default) and then try again.
