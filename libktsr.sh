#!/system/bin/sh
# KTSR by Pedro (pedrozzz0 @ GitHub)
# Credits: Draco (tytydraco @ GitHub), Dan (Paget69 @ XDA), mogoroku @ GitHub, helloklf @ GitHub, chenzyadb @ Gitee, Matt Yang (yc9559 @ GitHub) and Eight (dlwlrma123 @ GitHub).
# If you wanna use it as part of your project, please maintain the credits to it respective's author(s).

MODPATH=/data/adb/modules/KTSR

KLOG=/sdcard/KTSR/KTSR.log

KDBG=/sdcard/KTSR/KTSR_DBG.log

# Log in white and continue (unnecessary)
kmsg() {
	echo -e "[*] $@" >> $KLOG
	echo -e "[*] $@"
}

kmsg1() {
	echo -e "$@" >> $KDBG
	echo -e "$@"
}

kmsg2() {
	echo -e "[!] $@" >> $KDBG
	echo -e "[!] $@"
}

kmsg3() {
	echo -e "$@" >> $KLOG
	echo -e "$@"
}

toast() {
	am start -a android.intent.action.MAIN -e toasttext "Applying $kts_profile profile..." -n bellavita.toast/.MainActivity
}
	
toast1() {
	am start -a android.intent.action.MAIN -e toasttext "$kts_profile profile applied" -n bellavita.toast/.MainActivity
}

toastpt() {
	am start -a android.intent.action.MAIN -e toasttext "Aplicando perfil $kts_profilept..." -n bellavita.toast/.MainActivity
}

toastpt1() {
	am start -a android.intent.action.MAIN -e toasttext "Perfil $kts_profilept aplicado" -n bellavita.toast/.MainActivity
}

toasttr() {
	am start -a android.intent.action.MAIN -e toasttext "$kts_profiletr profili uygulanıyor..." -n bellavita.toast/.MainActivity
}

toasttr1() {
	am start -a android.intent.action.MAIN -e toasttext "$kts_profiletr profili uygulandı" -n bellavita.toast/.MainActivity
}

toastin() {
	am start -a android.intent.action.MAIN -e toasttext "Menerapkan profil $kts_profilein..." -n bellavita.toast/.MainActivity
}

toastin1() {
	am start -a android.intent.action.MAIN -e toasttext "Profil $kts_profilein terpakai" -n bellavita.toast/.MainActivity
}

toastfr() {
	am start -a android.intent.action.MAIN -e toasttext "Chargement du profil $kts_profilefr..." -n bellavita.toast/.MainActivity
}

toastfr1() {
	am start -a android.intent.action.MAIN -e toasttext "Profil $kts_profilefr chargé" -n bellavita.toast/.MainActivity
}

write() {
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]; then
	    kmsg2 "$1 doesn't exist, skipping..."
        return 1
     fi

	# Fetch the current key value
	local curval=$(cat "$1" 2> /dev/null)
	
	# Bail out if value is already set
	if [[ "$curval" == "$2" ]]; then
	    kmsg1 "$1 is already set to $2, skipping..."
	    return 0
	fi

	# Make file writable in case it is not already
	chmod +w "$1" 2> /dev/null

	# Write the new value and bail if there's an error
	if ! echo "$2" > "$1" 2> /dev/null
	then
	    kmsg2 "Failed: $1 -> $2"
		return 1
	fi
	
	# Log the success
	kmsg1 "$1 $curval -> $2"
}

# Duration in nanoseconds of one scheduling period
SCHED_PERIOD_LATENCY="$((1 * 1000 * 1000))"

SCHED_PERIOD_BALANCE="$((4 * 1000 * 1000))"
	
SCHED_PERIOD_BATTERY="$((8 * 1000 * 1000))"

SCHED_PERIOD_THROUGHPUT="$((10 * 1000 * 1000))"

# How many tasks should we have at a maximum in one scheduling period
SCHED_TASKS_LATENCY="10"

SCHED_TASKS_BATTERY="4"

SCHED_TASKS_BALANCE="8"

SCHED_TASKS_THROUGHPUT="6"

# Fetch GPU directories
get_gpu_dir() {
for gpul in /sys/devices/soc/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
 do
   if [[ -d "$gpul" ]]; then
   gpu=$gpul
   qcom=true
   fi
done
    
     for gpul1 in /sys/devices/soc.0/*.qcom,kgsl-3d0/kgsl/kgsl-3d0
     do
       if [[ -d "$gpul1" ]]; then
       gpu=$gpul1
       qcom=true
       fi
   done
       
      for gpul2 in /sys/devices/*.mali
      do
        if [[ -d "$gpul2" ]]; then
        gpu=$gpul2
        fi
    done
         
       for gpul3 in /sys/devices/platform/*.gpu
       do
         if [[ -d "$gpul3" ]]; then
         gpu=$gpul3
         fi
     done
       
         for gpul4 in /sys/devices/platform/mali-*.0
         do
           if [[ -d "$gpul4" ]]; then
           gpu=$gpul4
           fi
       done
           
           for gpul5 in /sys/devices/platform/*.mali
           do
             if [[ -d "$gpul5" ]]; then
             gpu=$gpul5
             fi
         done
                 
             for gpul6 in /sys/class/misc/mali*/device/devfreq/gpufreq
             do
               if [[ -d "$gpul6" ]]; then
               gpu=$gpul6
               fi
           done
             
              for gpul7 in /sys/class/misc/mali*/device/devfreq/*.gpu
              do
                if [[ -d "$gpul7" ]]; then
                gpu=$gpul7
                fi
            done

               for gpul8 in /sys/devices/platform/*.mali/misc/mali0
               do
                 if [[ -d "$gpul8" ]]; then
                 gpu=$gpul8
                 fi
             done

               if [[ -d "/sys/class/kgsl/kgsl-3d0" ]]; then
                   gpu="/sys/class/kgsl/kgsl-3d0"
                   qcom=true

               elif [[ -d "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0" ]]; then
                     gpu="/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0"
                     qcom=true

               elif [[ -d "/sys/devices/platform/gpusysfs" ]]; then
                     gpu="/sys/devices/platform/gpusysfs"

               elif [[ -d "/sys/devices/platform/mali.0" ]]; then
                     gpu="/sys/devices/platform/mali.0"

               elif [[ -d "/sys/class/misc/mali0/device" ]]; then
                     gpu="/sys/class/misc/mali0/device"
               fi
		
               if [[ -d "/sys/module/mali/parameters" ]]; then
                   gpug="/sys/module/mali/parameters/"
               fi
		
               if [[ -d "/sys/kernel/gpu" ]]; then
                   gpui="/sys/kernel/gpu/"
               fi
}

get_gpu_max() {
gpu_max=$(cat $gpu/devfreq/available_frequencies | awk -v var="$gpu_num_pl" '{print $var}')
    
if [[ $gpu_max -ne $gpu_max_freq ]]; then
    gpu_max=$(cat $gpu/devfreq/available_frequencies | awk 'NF>1{print $NF}')
    
elif [[ $gpu_max -ne $gpu_max_freq ]]; then
      gpu_max=$(cat $gpu/devfreq/available_frequencies | awk '{print $1}')
               
elif [[ $gpu_max -ne $gpu_max_freq ]]; then
      gpu_max=$gpu_max_freq
fi

if [[ -e "$gpu/available_frequencies" ]]; then
    gpu_max2=$(cat $gpu/available_frequencies | awk 'NF>1{print $NF}')
    
elif [[ $gpu_max2 -ne $gpu_max_freq ]]; then
      gpu_max2=$(cat $gpu/available_frequencies | awk '{print $1}')
    
elif [[ -e "$gpui/gpu_freq_table" ]]; then
      gpu_max2=$(cat $gpui/gpu_freq_table | awk 'NF>1{print $NF}')

elif [[ $gpu_max2 -ne $gpu_max_freq ]]; then
      gpu_max2=$(cat $gpui/gpu_freq_table | awk '{print $1}')
fi

      gpu_max3=$(cat /proc/gpufreq/gpufreq_opp_dump | awk '{printf $4 "\n"}' | cut -f1 -d "," | sed -n '1p')
}

get_gpu_min() {
if [[ -e "$gpu/available_frequencies" ]]; then
    gpu_min=$(cat $gpu/available_frequencies | awk '{print $1}')

elif [[ $gpu_min -ne $gpu_min_freq ]]; then
      gpu_min=$(cat $gpu/available_frequencies | awk 'NF>1{print $NF}')

elif [[ -e "$gpui/gpu_freq_table" ]]; then
      gpu_min=$(cat $gpui/gpu_freq_table | awk '{print $1}')

elif [[ $gpu_min -ne $gpu_min_freq ]]; then
      gpu_min=$(cat $gpui/gpu_freq_table | awk 'NF>1{print $NF}')
fi
}

get_cpu_gov() {
# Fetch CPU actual governor    
cpu_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
}

get_gpu_gov() {
# Fetch GPU actual governor
if [[ -e "$gpui/gpu_governor" ]]; then
    gpu_gov=$(cat $gpui/gpu_governor)
    
elif [[ -e "$gpu/governor" ]]; then
      gpu_gov=$(cat $gpu/governor)
    
elif [[ -e "$gpu/devfreq/governor" ]]; then
      gpu_gov=$(cat $gpu/devfreq/governor)
fi
}

check_qcom() {
# Check if qcom string is null, then define it as false
if [[ -z "$qcom" ]]; then
    qcom=false
fi
}

define_gpu_pl() {
# Fetch the GPU amount of power levels
gpu_num_pl=$(cat $gpu/num_pwrlevels)

# Fetch lower GPU power level
gpu_min_pl=$(cat $gpu/min_pwrlevel)

# Fetch higher GPU power level
gpu_max_pl=$(cat $gpu/max_pwrlevel)
}

get_max_cpu_clk() {
# Fetch max CPU clock
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  cpu_max_freq=$(cat $cpu/scaling_max_freq)
  cpu_max_freq2=$(cat $cpu/cpuinfo_max_freq)

if [[ "$cpu_max_freq2" -gt "$cpu_max_freq" ]]; then
    cpu_max_freq=$cpu_max_freq2
  fi
done
}

get_min_cpu_clk() {
# Fetch min CPU clock
cpu_min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
cpu_min_freq2=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)

if [[ "$cpu_min_freq" -gt "$cpu_min_freq2" ]]; then
    cpu_min_freq=$cpu_min_freq2
fi
}

get_cpu_min_max_mhz() {
# Fetch CPU min clock in MHz
cpu_min_clk_mhz=$((cpu_min_freq / 1000))

# Fetch CPU max clock in MHz
cpu_max_clk_mhz=$((cpu_max_freq / 1000))
}

get_gpu_min_max() {
# Fetch maximum GPU frequency (gpu_max & gpu_max2 does almost the same thing)
if [[ -e "$gpu/max_gpuclk" ]]; then
    gpu_max_freq=$(cat $gpu/max_gpuclk)

elif [[ -e "$gpu/max_clock" ]]; then
      gpu_max_freq=$(cat $gpu/max_clock)
fi

# Fetch minimum GPU frequency (gpumin also does almost the same thing)
if [[ -e "$gpu/min_clock_mhz" ]]; then
    gpu_min_freq=$(cat $gpu/min_clock_mhz)
    gpu_min_freq=$((gpu_min_freq * 1000000))

elif [[ -e "$gpu/min_clock" ]]; then
      gpu_min_freq=$(cat $gpu/min_clock)
fi
}

get_gpu_min_max_mhz() {
# Fetch maximum & minimum GPU clock in MHz
if [[ "$gpu_max_freq" -gt "100000" ]]; then
    gpu_max_clk_mhz=$((gpu_max_freq / 1000)); gpu_min_clk_mhz=$((gpu_min_freq / 1000))
fi

if [[ "$gpu_max_freq" -gt "100000000" ]]; then
    gpu_max_clk_mhz=$((gpu_max_freq / 1000000)); gpu_min_clk_mhz=$((gpu_min_freq / 1000000))
fi
}

get_soc_mf() {
# Fetch the SOC manufacturer
soc_mf=$(getprop ro.boot.hardware)
}

get_soc() {
# Fetch the device SOC
soc=$(getprop ro.board.platform)

if [[ $soc == "" ]]; then
    soc=$(getprop ro.product.board)

elif [[ $soc == "" ]]; then
      soc=$(getprop ro.product.platform)
fi
}

get_sdk() {
# Fetch the device SDK              
sdk=$(getprop ro.build.version.sdk)

if [[ $sdk == "" ]]; then
    sdk=$(getprop ro.vendor.build.version.sdk)

elif [[ $sdk == "" ]]; then
      sdk=$(getprop ro.vndk.version)
fi
}

get_arch() {
# Fetch the device architeture
arch=$(getprop ro.product.cpu.abi | awk -F "-" '{print $1}')
}

get_andro_vs() {
# Fetch the android version
avs=$(getprop ro.build.version.release)
}

get_dvc_cdn() {
# Fetch the device codename
dvc_cdn=$(getprop ro.product.device)
}

get_root() {
# Fetch root method
root=$(su -v)
}

# Detect if we're running on a exynos powered device
is_exynos() {
if [[ "$(getprop ro.boot.hardware | grep exynos)" ]] || [[ "$(getprop ro.board.platform | grep universal)" ]] || [[ "$(getprop ro.product.board | grep universal)" ]]; then
    exynos=true
    qcom=false

else
    exynos=false
fi
}

is_mtk() { 
# Detect if we're running on a mediatek powered device              
if [[ "$(getprop ro.board.platform | grep mt)" ]] || [[ "$(getprop ro.product.board | grep mt)" ]]; then
    mtk=true
    qcom=false
               
else
    mtk=false
fi
}

detect_cpu_sched() {
# Fetch the CPU scheduling type
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ "$(cat $cpu/scaling_available_governors | grep 'sched')" ]]; then
      cpu_sched=EAS

  elif [[ "$(cat $cpu/scaling_available_governors | grep 'interactive')" ]]; then
        cpu_sched=HMP

  else
      cpu_sched=Unknown
    fi
done
}

get_kern_info() {
# Fetch kernel name and version
kern_ver_name=$(uname -r)

# Fetch kernel build date
kern_bd_dt=$(uname -v | awk '{print $5, $6, $7, $8, $9, $10}')
}

get_ram_info() {
# Fetch the total amount of memory RAM
total_ram=$(busybox free -m | awk '/Mem:/{print $2}')

# Fetch the amount of available RAM
avail_ram=$(busybox free -m | grep Mem: | awk '{print $7}')
}

get_batt_pctg() {               
# Fetch battery actual capacity
if [[ -e "/sys/class/power_supply/battery/capacity" ]]; then
    batt_pctg=$(cat /sys/class/power_supply/battery/capacity)
              
else
    batt_pctg=$(dumpsys battery | awk '/level/{print $2}')
fi
}

get_ktsr_info() {
# Fetch KTSR version
build_ver=$(cat $MODPATH/module.prop | grep version= | sed "s/version=//")

# Fetch KTSR build type
build_tp=$(cat $MODPATH/ktsr.prop | grep buildtype= | sed "s/buildtype=//")

# Fetch KTSR build date
build_dt=$(cat $MODPATH/ktsr.prop | grep builddate= | sed "s/builddate=//")

# Fetch KTSR build codename
build_cdn=$(cat $MODPATH/ktsr.prop | grep codename= | sed "s/codename=//")
}

get_batt_tmp() {
# Fetch battery temperature
if [[ -e "/sys/class/power_supply/battery/temp" ]]; then
    batt_tmp=$(cat /sys/class/power_supply/battery/temp)

elif [[ -e "/sys/class/power_supply/battery/batt_temp" ]]; then 
      batt_tmp=$(cat /sys/class/power_supply/battery/batt_temp)

else 
    batt_tmp=$(dumpsys battery | awk '/temperature/{print $2}')
fi

# Ignore the battery temperature decimal
batt_tmp=$((batt_tmp / 10))
}

get_gpu_mdl() {
# Fetch GPU model
if [[ $exynos == "true" ]]; then
    gpu_mdl=$(cat $gpu/gpuinfo | awk '{print $1}')

elif [[ $mtk == "true" ]]; then
      gpu_mdl=$(dumpsys SurfaceFlinger | awk '/GLES/ {print $4,$5,$6}' | tr -d ,)

elif [[ $qcom == "true" ]]; then
      gpu_mdl=$(cat $gpui/gpu_model)

elif [[ $gpu_mdl == "" ]]; then
      gpu_mdl=$(dumpsys SurfaceFlinger | awk '/GLES/ {print $3,$4,$5}' | tr -d ,)
fi
}

get_drvs_info() {
# Fetch drivers info
if [[ $exynos == "true" ]]; then
    drvs_info=$(cat /sys/module/mali_kbase/version)

elif [[ $mtk == "true" ]]; then
      drvs_info=$(dumpsys SurfaceFlinger | awk '/GLES/ {print $7,$8,$9,$10,$11,$12,$13}')

else
    drvs_info=$(dumpsys SurfaceFlinger | awk '/GLES/ {print $6,$7,$8,$9,$10,$11,$12,$13}' | tr -d ,)
fi
}

get_rfrsh_rates() {
# Fetch supported refresh rates
rrs=$(dumpsys display | awk '/PhysicalDisplayInfo/{print $4}' | cut -c1-3 | tr -d .)

if [[ -z "$rrs" ]]; then
    rrs=$(dumpsys display | grep refreshRate | awk -F '=' '{print $6}' | cut -c1-3 | tr -d .)

elif [[ -z "$rrs" ]]; then
      rrs=$(dumpsys display | grep FrameRate | awk -F '=' '{print $6}' | cut -c1-3 | tr -d .)
fi
}

get_batt_hth() {
# Fetch battery health
if [[ -e "/sys/class/power_supply/battery/health" ]]; then
    batt_hth=$(cat /sys/class/power_supply/battery/health)

else
    batt_hth=$(dumpsys battery | awk '/health/{print $2}')
fi

if [[ $batt_hth == "1" ]]; then
    batt_hth=Unknown

elif [[ $batt_hth == "2" ]]; then
      batt_hth=Good

elif [[ $batt_hth == "3" ]]; then
      batt_hth=Overheat

elif [[ $batt_hth == "4" ]]; then
      batt_hth=Dead

elif [[ $batt_hth == "5" ]]; then
      batt_hth=Over voltage

elif [[ $batt_hth == "6" ]]; then
      batt_hth=Unspecified failure

elif [[ $batt_hth == "7" ]]; then
      batt_hth=Cold
               
else
    batt_hth=$batt_hth
fi
}

get_batt_sts() {
# Fetch battery status
if [[ -e "/sys/class/power_supply/battery/status" ]]; then
    batt_sts=$(cat /sys/class/power_supply/battery/status)

else
    batt_sts=$(dumpsys battery | awk '/status/{print $2}')
fi

if [[ $batt_sts == "1" ]]; then
    batt_sts=Unknown

elif [[ $batt_sts == "2" ]]; then
      batt_sts=Charging

elif [[ $batt_sts == "3" ]]; then
      batt_sts=Discharging

elif [[ $batt_sts == "4" ]]; then
      batt_sts=Not charging

elif [[ $batt_sts == "5" ]]; then
      batt_sts=Full

else
    batt_sts=$batt_sts
fi
}

get_batt_cpct() {
batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design)

if [[ "$batt_cpct" == "" ]]; then
    batt_cpct=$(dumpsys batterystats | grep Capacity: | awk '{print $2}' | cut -d "," -f 1)
fi
               
if [[ "$gbcapacity" -gt "1000000" ]]; then
    batt_cpct=$((batt_cpct / 1000))
fi
}

get_busy_ver() {
# Fetch busybox version
busy_ver=$(busybox | awk 'NR==1{print $2}')
}

get_rom_info() {
# Fetch ROM info
rom_info=$(getprop ro.build.display.id | awk '{print $1,$3,$4,$5}')
}

get_slnx_stt() {
# Fetch SELinux state
if [[ "$(cat /sys/fs/selinux/enforce)" == "1" ]]; then
    slnx_stt=Enforcing
               
else
    slnx_stt=Permissive
fi
}

setup_adreno_gpu_thrtl() {
gpu_thrtl_lvl=$(cat $gpu/thermal_pwrlevel)

# Disable the GPU thermal throttling clock restriction
if [[ "$gpu_thrtl_lvl" -eq "1" ]] && [[ "$gpu_thrtl_lvl" -gt "1" ]]; then
gpu_calc_thrtl=$((gpu_thrtl_lvl - gpu_thrtl_lvl))

else
    gpu_calc_thrtl=0
fi
}

get_gpu_load() {
# Fetch GPU load
if [[ -e "$gpui/gpu_busy_percentage" ]]; then
    gpu_load=$(cat $gpui/gpu_busy_percentage | tr -d %)

elif [[ -e "$gpu/utilization" ]]; then
      gpu_load=$(cat $gpu/utilization)
               
elif [[ -e "/proc/mali/utilization" ]]; then
      gpu_load=$(cat /proc/mali/utilization)

elif [[ -e "$gpu/load" ]]; then
      gpu_load=$(cat $gpu/load | tr -d %)

elif [[ -e "$gpui/gpu_busy" ]]; then
      gpu_load=$(cat $gpui/gpu_busy | tr -d %) 
fi
}

get_nr_cores() {
# Fetch the number of CPU cores
nr_cores=$(cat /sys/devices/system/cpu/possible | awk -F "-" '{print $2}')
               
nr_cores=$((nr_cores + 1))
               
if [[ "$nr_cores" -eq 0 ]]; then
    nr_cores=1
fi
}

get_dvc_brnd() {
# Fetch device brand
dvc_brnd=$(getprop ro.product.brand)
}

check_one_ui() {
# Check if we're running on OneUI
if [[ "$(getprop net.knoxscep.version)" ]] || [[ "$(getprop ril.product_code)" ]] || [[ "$(getprop ro.boot.em.model)" ]] || [[ "$(getprop net.knoxvpn.version)" ]] || [[ "$(getprop ro.securestorage.knox)" ]] || [[ "$(getprop gsm.version.ril-impl | grep Samsung)" ]] || [[ "$(getprop ro.build.PDA)" ]]; then
    one_ui=true

else
    one_ui=false
fi
}
               
get_dv() {
dv=$(getprop ro.boot.bootdevice)
}

get_uptime() {
# Fetch the amount of time since system is running
sys_uptime=$(uptime | awk '{print $3,$4}' | cut -d "," -f 1)
}

get_sql_info() {
if [[ "$(find /system -name "sqlite3" -type f)" ]]; then
    # Fetch SQLite version
    sql_ver=$(sqlite3 -version | awk '{print $1}')

    # Fetch SQLite build date
    sql_bd_dt=$(sqlite3 -version | awk '{print $2,$3}')
fi
}

get_cpu_load() {
# Calculate CPU load (50 ms)
read cpu user nice system idle iowait irq softirq steal guest< /proc/stat

cpu_active_prev=$((user+system+nice+softirq+steal))
cpu_total_prev=$((user+system+nice+softirq+steal+idle+iowait))

usleep 50000

read cpu user nice system idle iowait irq softirq steal guest< /proc/stat

cpu_active_cur=$((user+system+nice+softirq+steal))
cpu_total_cur=$((user+system+nice+softirq+steal+idle+iowait))

cpu_load=$((100*( cpu_active_cur-cpu_active_prev ) / (cpu_total_cur-cpu_total_prev) ))
}

get_all() {
get_gpu_dir

is_mtk

if [[ "$mtk" != "true" ]]; then
    is_exynos
fi

check_qcom

if [[ "$qcom" != "true" ]]; then
    support_ppm
fi

if [[ "$qcom" == "true" ]]; then
    define_gpu_pl
fi

get_gpu_max

get_gpu_min

get_cpu_gov

get_gpu_gov

get_max_cpu_clk

get_min_cpu_clk

get_cpu_min_max_mhz

get_gpu_min_max

get_gpu_min_max_mhz

get_soc_mf

get_soc

get_sdk

get_arch

get_andro_vs

get_dvc_cdn

get_root

detect_cpu_sched

get_kern_info

get_ram_info

get_batt_pctg

get_ktsr_info

get_batt_tmp

get_gpu_mdl

get_drvs_info

get_rfrsh_rates

get_batt_hth

get_batt_sts

get_batt_cpct

get_busy_ver

get_rom_info

get_slnx_stt

if [[ "$qcom" == "true" ]]; then
    setup_adreno_gpu_thrtl
fi

get_gpu_load

get_nr_cores

get_dvc_brnd

check_one_ui

get_dv

get_uptime

get_sql_info

get_cpu_load
}

###############################
# Abbreviations
###############################

tcp=/proc/sys/net/ipv4/

kernel=/proc/sys/kernel/

vm=/proc/sys/vm/

cpuset=/dev/cpuset/

stune=/dev/stune/

lmk=/sys/module/lowmemorykiller/

# Latency Profile
latency() {
init=$(date +%s)

get_all

kmsg3 ""  	
kmsg "General Info"

kmsg3 ""
kmsg3 "** Date of execution: $(date)"                                                                                    
kmsg3 "** Kernel: $kern_ver_name"                                                                                           
kmsg3 "** Kernel Build Date: $kern_bd_dt"
kmsg3 "** SOC: $soc_mf, $soc"                                                                                               
kmsg3 "** SDK: $sdk"
kmsg3 "** Android Version: $avs"    
kmsg3 "** CPU Governor: $cpu_gov"   
kmsg3 "** CPU Load: $cpu_load %"
kmsg3 "** Number of cores: $nr_cores"
kmsg3 "** CPU Freq: $cpu_min_clk_mhz-$cpu_max_clk_mhz MHz"
kmsg3 "** CPU Scheduling Type: $cpu_sched"                                                                               
kmsg3 "** AArch: $arch"        
kmsg3 "** GPU Load: $gpu_load%"
kmsg3 "** GPU Freq: $gpu_min_clk_mhz-$gpu_max_clk_mhz MHz"
kmsg3 "** GPU Model: $gpu_mdl"                                                                                         
kmsg3 "** GPU Drivers Info: $drvs_info"                                                                                  
kmsg3 "** GPU Governor: $gpu_gov"                                                                                  
kmsg3 "** Device: $dvc_brnd, $dvc_cdn"                                                                                                
kmsg3 "** ROM: $rom_info"                 
kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}')"
kmsg3 "** Screen Density: $(wm density | awk '{print $3}') PPI"
kmsg3 "** Supported Refresh Rates: $rrs HZ"                                                                                                    
kmsg3 "** KTSR Version: $build_ver"                                                                                     
kmsg3 "** KTSR Codename: $build_cdn"                                                                                   
kmsg3 "** Build Type: $build_tp"                                                                                         
kmsg3 "** Build Date: $build_dt"                                                                                          
kmsg3 "** Battery Charge Level: $batt_pctg %"  
kmsg3 "** Battery Capacity: $batt_cpct mAh"
kmsg3 "** Battery Health: $batt_hth"                                                                                     
kmsg3 "** Battery Status: $batt_sts"                                                                                     
kmsg3 "** Battery Temperature: $batt_tmp °C"                                                                               
kmsg3 "** Device RAM: $total_ram MB"                                                                                     
kmsg3 "** Device Available RAM: $avail_ram MB"
kmsg3 "** Root: $root"
kmsg3 "** SQLite Version: $sql_ver"
kmsg3 "** SQLite Build Date: $sql_bd_dt"
kmsg3 "** System Uptime: $sys_uptime"
kmsg3 "** SELinux: $slnx_stt"                                                                                   
kmsg3 "** Busybox: $busy_ver"
kmsg3 ""
kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
kmsg3 "** Telegram Channel: https://t.me/kingprojectz"
kmsg3 "** Telegram Group: https://t.me/kingprojectzdiscussion"
kmsg3 ""

# Disable perf and mpdecision
for v in 0 1 2 3 4; do
    stop vendor.qti.hardware.perf@$v.$v-service 2>/dev/null
    stop perf-hal-$v-$v 2>/dev/null
done

stop perfd 2>/dev/null
stop mpdecision 2>/dev/null
stop vendor.perfservice 2>/dev/null

if [[ -e "/data/system/perfd/default_values" ]]; then
    rm -f "/data/system/perfd/default_values"
fi

kmsg "Disabled perf and mpdecision"
kmsg3 ""

# Configure thermal profile
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "0"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "20"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "156"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]
then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "156"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid fiops bfq-sq bfq-mq bfq zen sio anxiety mq-deadline kyber cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
   write "${queue}add_random" 0
   write "${queue}iostats" 0
   write "${queue}rotational" 0
   write "${queue}read_ahead_kb" 32
   write "${queue}nomerges" 0
   write "${queue}rq_affinity" 2
   write "${queue}nr_requests" 16
done

kmsg "Tweaked I/O scheduler"
kmsg3 ""

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
   write "$governor/up_rate_limit_us" "0"
   write "$governor/down_rate_limit_us" "0"
   write "$governor/pl" "1"
   write "$governor/iowait_boost_enable" "1"
   write "$governor/rate_limit_us" "0"
   write "$governor/hispeed_load" "89"
   write "$governor/hispeed_freq" "$cpu_max_freq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
   write "$governor/timer_rate" "1000"
   write "$governor/boost" "0"
   write "$governor/timer_slack" "1000"
   write "$governor/input_boost" "0"
   write "$governor/use_migration_notif" "0" 
   write "$governor/ignore_hispeed_on_notif" "1"
   write "$governor/use_sched_load" "1"
   write "$governor/fastlane" "1"
   write "$governor/fast_ramp_down" "0"
   write "$governor/sampling_rate" "1000"
   write "$governor/sampling_rate_min" "1000"
   write "$governor/min_sample_time" "1000"
   write "$governor/go_hispeed_load" "89"
   write "$governor/hispeed_freq" "$cpu_max_freq"
done

if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "0"
fi

[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "1"

for i in 0 1 2 3 4 5 6 7 8 9
do
  write "/sys/devices/system/cpu/cpu$i/online" "1"
done

kmsg "Tweaked CPU parameters"
kmsg3 ""

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/devfreq/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/devfreq/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpui/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpui/gpu_governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/available_governors")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/governor" "$governor"
			break
		fi
	done
	
if [[ $qcom == "true" ]]; then
    write "$gpu/throttling" "1"
    write "$gpu/thermal_pwrlevel" "$gpu_calc_thrtl"
    write "$gpu/devfreq/adrenoboost" "0"
    write "$gpu/force_no_nap" "0"
    write "$gpu/bus_split" "1"
    write "$gpu/devfreq/max_freq" "$gpu_max_freq"
    write "$gpu/devfreq/min_freq" "100000000"
    write "$gpu/default_pwrlevel" "$((gpu_min_pl - 1))"
    write "$gpu/force_bus_on" "0"
    write "$gpu/force_clk_on" "0"
    write "$gpu/force_rail_on" "0"
    write "$gpu/idle_timer" "90"
    write "$gpu/pwrnap" "1"
else
    [[ $one_ui == "false" ]] && write "$gpu/dvfs" "1"
     write "$gpui/gpu_min_clock" "$gpu_min"
     write "$gpu/highspeed_clock" "$gpu_max_freq"
     write "$gpu/highspeed_load" "80"
     write "$gpu/highspeed_delay" "0"
     write "$gpu/power_policy" "coarse_demand"
     write "$gpui/boost" "0"
     write "$gpug/mali_touch_boost_level" "0"
     write "$gpu/max_freq" "$gpu_max_freq"
     write "$gpu/min_freq" "100000000"
     write "$gpu/tmu" "1"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync "1"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_upthreshold "60"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_downdifferential "40"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold "50"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential "30"
fi

if [[ -d "/sys/modules/ged/" ]]
then
    write "/sys/module/ged/parameters/ged_boost_enable" "0"
    write "/sys/module/ged/parameters/boost_gpu_enable" "0"
    write "/sys/module/ged/parameters/boost_extra" "0"
    write "/sys/module/ged/parameters/enable_cpu_boost" "0"
    write "/sys/module/ged/parameters/enable_gpu_boost" "0"
    write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
    write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
    write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
    write "/sys/module/ged/parameters/ged_smart_boost" "0"
    write "/sys/module/ged/parameters/gpu_debug_enable" "0"
    write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
    write "/sys/module/ged/parameters/gx_3D_benchmark_on" "0"
    write "/sys/module/ged/parameters/gx_dfps" "0"
    write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
    write "/sys/module/ged/parameters/gx_frc_mode" "0"
    write "/sys/module/ged/parameters/gx_game_mode" "0"
    write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
fi

if [[ -d "/proc/gpufreq/" ]] 
then
    write "/proc/gpufreq/gpufreq_input_boost" "0"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
fi

# Tweak some mali parameters
if [[ -d "/proc/mali/" ]] 
then
     [[ $one_ui == "false" ]] && write "/proc/mali/dvfs_enable" "1"
     write "/proc/mali/always_on" "0"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
    write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "Y"
fi

kmsg "Tweaked GPU parameters"
kmsg3 ""

# Schedtune Tweaks
if [[ -d "$stune" ]]; then
    write "${stune}background/schedtune.boost" "0"
    write "${stune}background/schedtune.prefer_idle" "0"
    write "${stune}background/schedtune.sched_boost" "0"
    write "${stune}background/schedtune.prefer_perf" "0"

    write "${stune}foreground/schedtune.boost" "0"
    write "${stune}foreground/schedtune.prefer_idle" "0"
    write "${stune}foreground/schedtune.sched_boost" "0"
    write "${stune}foreground/schedtune.sched_boost_no_override" "1"
    write "${stune}foreground/schedtune.prefer_perf" "0"

    write "${stune}rt/schedtune.boost" "0"
    write "${stune}rt/schedtune.prefer_idle" "0"
    write "${stune}rt/schedtune.sched_boost" "0"
    write "${stune}rt/schedtune.prefer_perf" "0"

    write "${stune}top-app/schedtune.boost" "15"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "0"
    write "${stune}top-app/schedtune.sched_boost_no_override" "1"
    write "${stune}top-app/schedtune.prefer_perf" "1"

    write "${stune}schedtune.boost" "0"
    write "${stune}schedtune.prefer_idle" "0"
    kmsg "Tweaked cpuset schedtune"
    kmsg3 ""
fi

# Uclamp Tweaks
if [[ -e "${cpuset}top-app/uclamp.max" ]]
then
    sysctl -w kernel.sched_util_clamp_min_rt_default=16
    sysctl -w kernel.sched_util_clamp_min=64

    write "${cpuset}top-app/uclamp.max" "max"
    write "${cpuset}top-app/uclamp.min" "20"
    write "${cpuset}top-app/uclamp.boosted" "1"
    write "${cpuset}top-app/uclamp.latency_sensitive" "1"

    write "${cpuset}foreground/uclamp.max" "max"
    write "${cpuset}foreground/uclamp.min" "10"
    write "${cpuset}foreground/uclamp.boosted" "0"
    write "${cpuset}foreground/uclamp.latency_sensitive" "0"

    write "${cpuset}background/uclamp.max" "50"
    write "${cpuset}background/uclamp.min" "0"
    write "${cpuset}background/uclamp.boosted" "0"
    write "${cpuset}background/uclamp.latency_sensitive" "0"

    write "${cpuset}system-background/uclamp.max" "40"
    write "${cpuset}system-background/uclamp.min" "0"
    write "${cpuset}system-background/uclamp.boosted" "0"
    write "${cpuset}system-background/uclamp.latency_sensitive" "0"
    kmsg "Tweaked cpuset uclamp"
    kmsg3 ""
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
    write "/proc/sys/fs/dir-notify-enable" "0"
    write "/proc/sys/fs/lease-break-time" "10"
    write "/proc/sys/fs/leases-enable" "1"
    write "/proc/sys/fs/inotify/max_queued_events" "131072"
    write "/proc/sys/fs/inotify/max_user_watches" "131072"
    write "/proc/sys/fs/inotify/max_user_instances" "1024"
    kmsg "Tweaked FS"
    kmsg3 ""
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
    write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
    kmsg "Enabled dynamic fsync"
    kmsg3 ""
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
    write "/sys/kernel/debug/sched_features" "UTIL_EST"
    [[ $cpu_sched == "EAS" ]] && write "/sys/kernel/debug/sched_features" "EAS_PREFER_IDLE"
     kmsg "Tweaked scheduler features"
     kmsg3 ""
fi

if [[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]]; then
     write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
     kmsg "Disabled MMC CRC"
     kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/removable" ]]; then
      write "/sys/module/mmc_core/parameters/removable" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/crc" ]]; then
      write "/sys/module/mmc_core/parameters/crc" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""
fi

# Tweak some kernel settings to improve overall performance.
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "1"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "4"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "1"
fi
if [[ -e "/sys/devices/soc/$dv/clkscale_enable" ]]; then
    write "/sys/devices/soc/$dv/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkgate_enable" ]]; then
    write "/sys/devices/soc/$dv/clkgate_enable" "1"
fi
write "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "10000000"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "1250000"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "2000000"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "5000000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "4"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "/proc/ufs_perf" ]]; then
    write "/proc/ufs_perf" "0"
fi
if [[ -e "/proc/cpuidle/enable" ]]; then
    write "/proc/cpuidle/enable" "1"
fi
if [[ -e "/sys/kernel/debug/eara_thermal/enable" ]]; then
    write "/sys/kernel/debug/eara_thermal/enable" "0"
fi

# Enable UTW (UFS Turbo Write)
for ufs in /sys/devices/platform/soc/*.ufshc/ufstw_lu*; do
   if [[ -d "$ufs" ]]; then
       write "${ufs}tw_enable" "1"
       kmsg "Enabled UFS Turbo Write"
       kmsg3 ""
     fi
  break
done

if [[ -e "/sys/power/little_thermal_temp" ]]; then
    write "/sys/power/little_thermal_temp" "90"
fi

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy_status" "1 0"
    write "/proc/ppm/policy_status" "2 0"
    write "/proc/ppm/policy_status" "3 0"
    write "/proc/ppm/policy_status" "4 1"
    write "/proc/ppm/policy_status" "7 0"
    write "/proc/ppm/policy_status" "9 0"
fi

kmsg "Tweaked various kernel parameters"
kmsg3 ""

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_min_freq"
    write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_min_freq"
    write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
    write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
fi

# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

kmsg "Tweaked CPU clocks"
kmsg3 ""

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
    write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
    kmsg "Allowed CPUs to use it's deepest sleep state"
    kmsg3 ""
fi

fr=$(((total_ram * 2 / 100) * 1024 / 4))
bg=$(((total_ram * 3 / 100) * 1024 / 4))
et=$(((total_ram * 4 / 100) * 1024 / 4))
mr=$(((total_ram * 6 / 100) * 1024 / 4))
cd=$(((total_ram * 9 / 100) * 1024 / 4))
ab=$(((total_ram * 12 / 100) * 1024 / 4))

efr=$((mfr * 16 / 5))

if [[ "$efr" -le "18432" ]]; then
    efr=18432
fi

mfr=$((total_ram * 9 / 5))

if [[ "$mfr" -le "3072" ]]; then
    mfr=3072
fi

# always sync before dropping caches
sync

# VM tweaks to improve overall user experience and smoothness.
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "25"
write "${vm}dirty_expire_centisecs" "3000"
write "${vm}dirty_writeback_centisecs" "3000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Use SSWAP defaults if device haven't more than 3 GB RAM on exynos SOC's
if [[ $exynos == "true" ]] && [[ $total_ram -lt "3000" ]]; then
    write "${vm}swappiness" "150"
else
    write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "200"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]] && [[ $total_ram -lt "5000" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
write "${vm}reap_mem_on_sigkill" "1"

# Tune lmk_minfree
if [[ -e "${lmk}/parameters/minfree" ]]; then
    write "${lmk}/parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

# Enable oom_reaper
if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
# Disable lmk_fast_run
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "0"
fi

# Disable adaptive_lmk
if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

# Tune vm_min_free_kbytes
if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
# Tune vm_extra_free_kbytes
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

kmsg "Tweaked various VM / LMK parameters for a improved user-experience"
kmsg3 ""

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
    write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
    write "/sys/module/msm_thermal/core_control/enabled" "0"
    write "/sys/module/msm_thermal/parameters/enabled" "N"
    kmsg "Tweaked msm_thermal"
    kmsg3 ""
fi

# Disable CPU power efficient workqueue
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
    write "/sys/module/workqueue/parameters/power_efficient" "N"
    kmsg "Disabled CPU power efficient workqueue"
    kmsg3 ""
fi

# Disable CPU scheduler multi-core power-saving
if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
    kmsg "Disabled CPU scheduler multi-core power-saving"
    kmsg3 ""
fi

# Fetch the available TCP congestion control 
avail_con="$(cat "${tcp}tcp_available_congestion_control")"
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr westwood cubic  
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# TCP Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg "Applied TCP tweaks"
kmsg3 ""

# Disable kernel battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
    write "/sys/module/battery_saver/parameters/enabled" "N"
    kmsg "Disabled kernel battery saver"
    kmsg3 ""
fi

# Enable USB 3.0 fast charging
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
    write "/sys/kernel/fast_charge/force_fast_charge" "1"
    kmsg "Enabled USB 3.0 fast charging"
    kmsg3 ""
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
    write "/sys/class/sec/switch/afc_disable" "0"
    kmsg "Enabled fast charging on Samsung devices"
    kmsg3 ""
fi

kmsg "Latency profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exectime=$((exit - init))
kmsg "Elapsed time: $exectime seconds."
}
# Automatic Profile
automatic() {     	
kmsg "Applying automatic profile"
kmsg3 ""

sync
kingauto
	
kmsg "Applied automatic profile"
kmsg3 ""
}
# Balanced Profile
balanced() {
init=$(date +%s)

get_all

kmsg3 ""  	
kmsg "General Info"

kmsg3 ""
kmsg3 "** Date of execution: $(date)"                                                                                    
kmsg3 "** Kernel: $kern_ver_name"                                                                                           
kmsg3 "** Kernel Build Date: $kern_bd_dt"
kmsg3 "** SOC: $soc_mf, $soc"                                                                                               
kmsg3 "** SDK: $sdk"
kmsg3 "** Android Version: $avs"    
kmsg3 "** CPU Governor: $cpu_gov"   
kmsg3 "** CPU Load: $cpu_load %"
kmsg3 "** Number of cores: $nr_cores"
kmsg3 "** CPU Freq: $cpu_min_clk_mhz-$cpu_max_clk_mhz MHz"
kmsg3 "** CPU Scheduling Type: $cpu_sched"                                                                               
kmsg3 "** AArch: $arch"        
kmsg3 "** GPU Load: $gpu_load%"
kmsg3 "** GPU Freq: $gpu_min_clk_mhz-$gpu_max_clk_mhz MHz"
kmsg3 "** GPU Model: $gpu_mdl"                                                                                         
kmsg3 "** GPU Drivers Info: $drvs_info"                                                                                  
kmsg3 "** GPU Governor: $gpu_gov"                                                                                  
kmsg3 "** Device: $dvc_brnd, $dvc_cdn"                                                                                                
kmsg3 "** ROM: $rom_info"                 
kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}')"
kmsg3 "** Screen Density: $(wm density | awk '{print $3}') PPI"
kmsg3 "** Supported Refresh Rates: $rrs HZ"                                                                                                    
kmsg3 "** KTSR Version: $build_ver"                                                                                     
kmsg3 "** KTSR Codename: $build_cdn"                                                                                   
kmsg3 "** Build Type: $build_tp"                                                                                         
kmsg3 "** Build Date: $build_dt"                                                                                          
kmsg3 "** Battery Charge Level: $batt_pctg %"  
kmsg3 "** Battery Capacity: $batt_cpct mAh"
kmsg3 "** Battery Health: $batt_hth"                                                                                     
kmsg3 "** Battery Status: $batt_sts"                                                                                     
kmsg3 "** Battery Temperature: $batt_tmp °C"                                                                               
kmsg3 "** Device RAM: $total_ram MB"                                                                                     
kmsg3 "** Device Available RAM: $avail_ram MB"
kmsg3 "** Root: $root"
kmsg3 "** SQLite Version: $sql_ver"
kmsg3 "** SQLite Build Date: $sql_bd_dt"
kmsg3 "** System Uptime: $sys_uptime"
kmsg3 "** SELinux: $slnx_stt"                                                                                   
kmsg3 "** Busybox: $busy_ver"
kmsg3 ""
kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
kmsg3 "** Telegram Channel: https://t.me/kingprojectz"
kmsg3 "** Telegram Group: https://t.me/kingprojectzdiscussion"
kmsg3 ""

# Disable perf and mpdecision
for v in 0 1 2 3 4; do
    stop vendor.qti.hardware.perf@$v.$v-service 2>/dev/null
    stop perf-hal-$v-$v 2>/dev/null
done

stop perfd 2>/dev/null
stop mpdecision 2>/dev/null
stop vendor.perfservice 2>/dev/null

if [[ -e "/data/system/perfd/default_values" ]]; then
    rm -f "/data/system/perfd/default_values"
fi

kmsg "Disabled perf and mpdecision"
kmsg3 ""

# Configure thermal profile
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "0"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "15"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
  if [[ -e "${corectl}/enable" ]]
  then
      write "${corectl}/enable" "0"

  elif [[ -e "${corectl}/disable" ]]
  then
      write "${corectl}/disable" "1"
   fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
    write "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
    write "/sys/power/cpuhotplug/enabled" "0"
fi

if [[ -e "/sys/kernel/intelli_plug" ]]; then
    write "/sys/kernel/intelli_plug/intelli_plug_active" "0"
fi

if [[ -e "/sys/module/blu_plug" ]]; then
    write "/sys/module/blu_plug/parameters/enabled" "0"
fi

if [[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]]; then
    write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
fi

if [[ -e "/sys/module/autosmp" ]]; then
    write "/sys/module/autosmp/parameters/enabled" "0"
fi
 
if [[ -e "/sys/kernel/zen_decision" ]]; then
    write "/sys/kernel/zen_decision/enabled" "0"
fi

if [[ -e "/proc/hps" ]]; then
    write "/proc/hps/enabled" "0"
fi

kmsg "Disabled core control & CPU hotplug"
kmsg3 ""

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "128"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]
then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "128"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid fiops bfq-sq bfq-mq bfq zen sio anxiety mq-deadline kyber cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
   write "${queue}add_random" 0
   write "${queue}iostats" 0
   write "${queue}rotational" 0
   write "${queue}read_ahead_kb" 64
   write "${queue}nomerges" 1
   write "${queue}rq_affinity" 2
   write "${queue}nr_requests" 128
done

kmsg "Tweaked I/O scheduler"
kmsg3 ""

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
   write "$governor/up_rate_limit_us" "$((SCHED_PERIOD_BALANCE / 1000))"
   write "$governor/down_rate_limit_us" "$((4 * SCHED_PERIOD_BALANCE / 1000))"
   write "$governor/pl" "1"
   write "$governor/iowait_boost_enable" "1"
   write "$governor/rate_limit_us" "$((4 * SCHED_PERIOD_BALANCE / 1000))"
   write "$governor/hispeed_load" "89"
   write "$governor/hispeed_freq" "$cpu_max_freq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
  write "$governor/timer_rate" "42000"
  write "$governor/boost" "0"
  write "$governor/timer_slack" "42000"
  write "$governor/input_boost" "0"
  write "$governor/use_migration_notif" "0" 
  write "$governor/ignore_hispeed_on_notif" "1"
  write "$governor/use_sched_load" "1"
  write "$governor/boostpulse" "0"
  write "$governor/fastlane" "1"
  write "$governor/fast_ramp_down" "0"
  write "$governor/sampling_rate" "42000"
  write "$governor/sampling_rate_min" "50000"
  write "$governor/min_sample_time" "50000"
  write "$governor/go_hispeed_load" "89"
  write "$governor/hispeed_freq" "$cpu_max_freq"
done

if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "0"
fi

[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "1"

for i in 0 1 2 3 4 5 6 7 8 9
do
  write "/sys/devices/system/cpu/cpu$i/online" "1"
done

kmsg "Tweaked CPU parameters"
kmsg3 ""

if [[ -e "/sys/kernel/hmp" ]]; then
    write "/sys/kernel/hmp/boost" "0"
    write "/sys/kernel/hmp/down_compensation_enabled" "1"
    write "/sys/kernel/hmp/family_boost" "0"
    write "/sys/kernel/hmp/semiboost" "0"
    write "/sys/kernel/hmp/up_threshold" "575"
    write "/sys/kernel/hmp/down_threshold" "256"
    kmsg "Tweaked HMP parameters"
    kmsg3 ""
fi

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/devfreq/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/devfreq/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpui/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpui/gpu_governor" "$governor"
			break
		fi
	done
	
    # Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/available_governors")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/governor" "$governor"
			break
		fi
	done

if [[ $qcom == "true" ]]; then
    write "$gpu/throttling" "1"
    write "$gpu/thermal_pwrlevel" "$gpu_calc_thrtl"
    write "$gpu/devfreq/adrenoboost" "0"
    write "$gpu/force_no_nap" "0"
    write "$gpu/bus_split" "1"
    write "$gpu/devfreq/max_freq" "$gpu_max_freq"
    write "$gpu/devfreq/min_freq" "100000000"
    write "$gpu/default_pwrlevel" "$gpu_min_pl"
    write "$gpu/force_bus_on" "0"
    write "$gpu/force_clk_on" "0"
    write "$gpu/force_rail_on" "0"
    write "$gpu/idle_timer" "66"
    write "$gpu/pwrnap" "1"
else
    [[ $one_ui == "false" ]] && write "$gpu/dvfs" "1"
     write "$gpui/gpu_min_clock" "$gpu_min"
     write "$gpu/highspeed_clock" "$gpu_max_freq"
     write "$gpu/highspeed_load" "86"
     write "$gpu/highspeed_delay" "0"
     write "$gpu/power_policy" "coarse_demand"
     write "$gpui/boost" "0"
     write "$gpug/mali_touch_boost_level" "0"
     write "$gpu/max_freq" "$gpu_max_freq"
     write "$gpu/min_freq" "100000000"
     write "$gpu/tmu" "1"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync "1"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_upthreshold "70"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_downdifferential "45"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold "65"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential "40"
fi

if [[ -d "/sys/modules/ged/" ]]
then
    write "/sys/module/ged/parameters/ged_boost_enable" "0"
    write "/sys/module/ged/parameters/boost_gpu_enable" "0"
    write "/sys/module/ged/parameters/boost_extra" "0"
    write "/sys/module/ged/parameters/enable_cpu_boost" "0"
    write "/sys/module/ged/parameters/enable_gpu_boost" "0"
    write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
    write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
    write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
    write "/sys/module/ged/parameters/ged_smart_boost" "0"
    write "/sys/module/ged/parameters/gpu_debug_enable" "0"
    write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
    write "/sys/module/ged/parameters/gx_3D_benchmark_on" "0"
    write "/sys/module/ged/parameters/gx_dfps" "0"
    write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
    write "/sys/module/ged/parameters/gx_frc_mode" "0"
    write "/sys/module/ged/parameters/gx_game_mode" "0"
    write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
fi

if [[ -d "/proc/gpufreq/" ]] 
then
    write "/proc/gpufreq/gpufreq_opp_freq" "0"
    write "/proc/gpufreq/gpufreq_input_boost" "0"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
fi

# Tweak some mali parameters
if [[ -d "/proc/mali/" ]] 
then
     [[ $one_ui == "false" ]] && write "/proc/mali/dvfs_enable" "1"
     write "/proc/mali/always_on" "0"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
    write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "Y"
fi

kmsg "Tweaked GPU parameters"
kmsg3 ""

if [[ -e "/sys/module/cryptomgr/parameters/notests" ]]
then
    write "/sys/module/cryptomgr/parameters/notests" "Y"
    kmsg "Disabled forced cryptography tests"
    kmsg3 ""
fi

# Enable and tweak adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
     write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
     write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "5000"
     write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "35"
     write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "25"
     kmsg "Enabled and tweaked adreno idler"
     kmsg3 ""
fi

# Schedtune Tweaks
if [[ -d "$stune" ]]
then
    write "${stune}background/schedtune.boost" "0"
    write "${stune}background/schedtune.prefer_idle" "0"
    write "${stune}background/schedtune.sched_boost" "0"
    write "${stune}background/schedtune.prefer_perf" "0"

    write "${stune}foreground/schedtune.boost" "0"
    write "${stune}foreground/schedtune.prefer_idle" "0"
    write "${stune}foreground/schedtune.sched_boost" "0"
    write "${stune}foreground/schedtune.sched_boost_no_override" "1"
    write "${stune}foreground/schedtune.prefer_perf" "0"

    write "${stune}rt/schedtune.boost" "0"
    write "${stune}rt/schedtune.prefer_idle" "0"
    write "${stune}rt/schedtune.sched_boost" "0"
    write "${stune}rt/schedtune.prefer_perf" "0"

    write "${stune}top-app/schedtune.boost" "10"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "0"
    write "${stune}top-app/schedtune.sched_boost_no_override" "1"
    write "${stune}top-app/schedtune.prefer_perf" "1"

    write "${stune}schedtune.boost" "0"
    write "${stune}schedtune.prefer_idle" "0"
    kmsg "Tweaked cpuset schedtune"
    kmsg3 ""
fi

# Uclamp Tweaks
if [[ -e "${cpuset}top-app/uclamp.max" ]]
then
    sysctl -w kernel.sched_util_clamp_min_rt_default=32
    sysctl -w kernel.sched_util_clamp_min=128

    write "${cpuset}top-app/uclamp.max" "max"
    write "${cpuset}top-app/uclamp.min" "10"
    write "${cpuset}top-app/uclamp.boosted" "1"
    write "${cpuset}top-app/uclamp.latency_sensitive" "1"

    write "${cpuset}foreground/uclamp.max" "max"
    write "${cpuset}foreground/uclamp.min" "5"
    write "${cpuset}foreground/uclamp.boosted" "0"
    write "${cpuset}foreground/uclamp.latency_sensitive" "0"

    write "${cpuset}background/uclamp.max" "50"
    write "${cpuset}background/uclamp.min" "0"
    write "${cpuset}background/uclamp.boosted" "0"
    write "${cpuset}background/uclamp.latency_sensitive" "0"

    write "${cpuset}system-background/uclamp.max" "40"
    write "${cpuset}system-background/uclamp.min" "0"
    write "${cpuset}system-background/uclamp.boosted" "0"
    write "${cpuset}system-background/uclamp.latency_sensitive" "0"
    kmsg "Tweaked cpuset uclamp"
    kmsg3 ""
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
    write "/proc/sys/fs/dir-notify-enable" "0"
    write "/proc/sys/fs/lease-break-time" "10"
    write "/proc/sys/fs/leases-enable" "1"
    write "/proc/sys/fs/inotify/max_queued_events" "131072"
    write "/proc/sys/fs/inotify/max_user_watches" "131072"
    write "/proc/sys/fs/inotify/max_user_instances" "1024"
    kmsg "Tweaked FS"
    kmsg3 ""
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
    write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
    kmsg "Enabled dynamic fsync"
    kmsg3 ""
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    write "/sys/kernel/debug/sched_features" "UTIL_EST"
    [[ $cpu_sched == "EAS" ]] && write "/sys/kernel/debug/sched_features" "EAS_PREFER_IDLE"
     kmsg "Tweaked scheduler features"
     kmsg3 ""
fi

if [[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]]; then
    write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
    kmsg "Disabled MMC CRC"
    kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/removable" ]]; then
      write "/sys/module/mmc_core/parameters/removable" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/crc" ]]; then
      write "/sys/module/mmc_core/parameters/crc" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""
fi

# Tweak some kernel settings to improve overall performance
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "1"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "6"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "1"
fi
if [[ -e "/sys/devices/soc/$dv/clkscale_enable" ]]; then
    write "/sys/devices/soc/$dv/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkgate_enable" ]]; then
    write "/sys/devices/soc/$dv/clkgate_enable" "1"
fi
write "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "$SCHED_PERIOD_BALANCE"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_BALANCE / SCHED_TASKS_BALANCE))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BALANCE / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "5000000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "32"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    write "${kernel}sched_boost" "0"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "/proc/ufs_perf" ]]; then
    write "/proc/ufs_perf" "0"
fi
if [[ -e "/proc/cpuidle/enable" ]]; then
    write "/proc/cpuidle/enable" "1"
fi
if [[ -e "/sys/kernel/debug/eara_thermal/enable" ]]; then
    write "/sys/kernel/debug/eara_thermal/enable" "0"
fi

# Disable UTW (UFS Turbo Write)
for ufs in /sys/devices/platform/soc/*.ufshc/ufstw_lu*; do
   if [[ -d "$ufs" ]]; then
       write "${ufs}tw_enable" "0"
       kmsg "Disabled UFS Turbo Write"
       kmsg3 ""
     fi
  break
done

if [[ -e "/sys/power/little_thermal_temp" ]]; then
    write "/sys/power/little_thermal_temp" "90"
fi

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy_status" "1 0"
    write "/proc/ppm/policy_status" "2 0"
    write "/proc/ppm/policy_status" "3 0"
    write "/proc/ppm/policy_status" "4 1"
    write "/proc/ppm/policy_status" "7 0"
    write "/proc/ppm/policy_status" "9 0"
fi

kmsg "Tweaked various kernel parameters"
kmsg3 ""

# Enable fingerprint boost
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
    write "/sys/kernel/fp_boost/enabled" "1"
    kmsg "Enabled fingerprint boost"
    kmsg3 ""
fi

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_min_freq"
    write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_min_freq"
    write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
    write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
fi

# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cores}scaling_min_freq" "$cpu_min_freq"
      write "${cores}scaling_max_freq" "$cpu_max_freq"
   fi
done

kmsg "Tweaked CPU clocks"
kmsg3 ""

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
    write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
    kmsg "Allowed CPUs to use it's deepest sleep state"
    kmsg3 ""
fi

# Disable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
    write "/sys/module/acpuclock_krait/parameters/boost" "N"
    kmsg "Disabled krait voltage boost"
    kmsg3 ""
fi

fr=$(((total_ram * 5 / 2 / 100) * 1024 / 4))
bg=$(((total_ram * 3 / 100) * 1024 / 4))
et=$(((total_ram * 5 / 100) * 1024 / 4))
mr=$(((total_ram * 7 / 100) * 1024 / 4))
cd=$(((total_ram * 9 / 100) * 1024 / 4))
ab=$(((total_ram * 11 / 100) * 1024 / 4))

mfr=$((total_ram * 8 / 5))

if [[ "$mfr" -le "3072" ]]; then
    mfr=3072
fi

# Extra free kbytes calculated based on min_free_kbytes
efr=$((mfr * 16 / 5))

if [[ "$efr" -le "18432" ]]; then
    efr=18432
fi

# always sync before dropping caches
sync

# VM settings to improve overall user experience and smoothness.
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "25"
write "${vm}dirty_expire_centisecs" "1000"
write "${vm}dirty_writeback_centisecs" "3000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Use SSWAP defaults if device haven't more than 3 GB RAM on exynos SOC's
if [[ $exynos == "true" ]] && [[ $total_ram -lt "3000" ]]; then
    write "${vm}swappiness" "150"
else
    write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "100"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]] | [[ $total_ram -lt "5000" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
write "${vm}reap_mem_on_sigkill" "1"

# Tune lmk_minfree
if [[ -e "${lmk}parameters/minfree" ]]; then
    write "${lmk}/parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

# Enable oom_reaper
if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
# Enable lmk_fast_run
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

# Disable adaptive_lmk
if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

# Tune vm_min_free_kbytes
if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
# Tune vm_extra_free_kbytes
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
    write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
    write "/sys/module/msm_thermal/core_control/enabled" "0"
    write "/sys/module/msm_thermal/parameters/enabled" "N"
    kmsg "Tweaked msm_thermal"
    kmsg3 ""
fi

# Enable CPU power efficient workqueue
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
    write "/sys/module/workqueue/parameters/power_efficient" "Y"
    kmsg "Enabled CPU power efficient workqueue"
    kmsg3 ""
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "1"
    kmsg "Enabled CPU scheduler multi-core power-saving"
    kmsg3 ""
fi

# Fix DT2W
if [[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]]
then
    write "/sys/touchpanel/double_tap" "1"
    write "/proc/tp_gesture" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/class/sec/tsp/dt2w_enable" ]]
then
    write "/sys/class/sec/tsp/dt2w_enable" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/proc/tp_gesture" ]]
then
    write "/proc/tp_gesture" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
    write "/sys/touchpanel/double_tap" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""
fi

# Disable touch boost on balance and battery profile
if [[ -e "/sys/module/msm_performance/parameters/touchboost" ]]
then
    write "/sys/module/msm_performance/parameters/touchboost" "0"
    kmsg "Disabled msm_performance touch boost"
    kmsg3 ""

elif [[ -e "/sys/power/pnpmgr/touch_boost" ]]
then
    write "/sys/power/pnpmgr/touch_boost" "0"
    write "/sys/power/pnpmgr/long_duration_touch_boost" "0"
    kmsg "Disabled pnpmgr touch boost"
    kmsg3 ""
fi

# Fetch the available TCP congestion control 
avail_con="$(cat "${tcp}tcp_available_congestion_control")"
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr westwood cubic 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# TCP Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg "Applied TCP tweaks"
kmsg3 ""

# Enable kernel battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
    write "/sys/module/battery_saver/parameters/enabled" "Y"
    kmsg "Enabled kernel battery saver"
    kmsg3 ""
fi

# Disable high performance audio
for hpm in /sys/module/snd_soc_wcd*
do
  if [[ -e "$hpm" ]]
  then
      write "${hpm}/parameters/high_perf_mode" "0"
      kmsg "Disabled high performance audio"
      kmsg3 ""
      break
   fi
done

# Enable LPM in balanced / battery profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
  if [[ -d "/sys/module/lpm_levels" ]]
  then
      write "/sys/module/lpm_levels/parameters/lpm_prediction" "Y"
      write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "Y"
      write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
      write "${lpm}idle_enabled" "Y"
      write "${lpm}suspend_enabled" "Y"
   fi
done

kmsg "Enabled LPM"
kmsg3 ""

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]] 
then
    write "/sys/module/pm2/parameters/idle_sleep_mode" "Y"
    kmsg "Enabled pm2 idle sleep mode"
    kmsg3 ""
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
    write "/sys/class/lcd/panel/power_reduce" "0"
    kmsg "Enabled LCD power reduce"
    kmsg3 ""
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
    write "/sys/kernel/fast_charge/force_fast_charge" "1"
    kmsg "Enabled USB 3.0 fast charging"
    kmsg3 ""
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
    write "/sys/class/sec/switch/afc_disable" "0"
    kmsg "Enabled fast charging on Samsung devices"
    kmsg3 ""
fi

kmsg "Balanced profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exectime=$((exit - init))
kmsg "Elapsed time: $exectime seconds."
}
# Extreme Profile
extreme() {
init=$(date +%s)

get_all
  	
kmsg3 ""  	
kmsg "General Info"

kmsg3 ""
kmsg3 "** Date of execution: $(date)"                                                                                    
kmsg3 "** Kernel: $kern_ver_name"                                                                                           
kmsg3 "** Kernel Build Date: $kern_bd_dt"
kmsg3 "** SOC: $soc_mf, $soc"                                                                                               
kmsg3 "** SDK: $sdk"
kmsg3 "** Android Version: $avs"    
kmsg3 "** CPU Governor: $cpu_gov"   
kmsg3 "** CPU Load: $cpu_load %"
kmsg3 "** Number of cores: $nr_cores"
kmsg3 "** CPU Freq: $cpu_min_clk_mhz-$cpu_max_clk_mhz MHz"
kmsg3 "** CPU Scheduling Type: $cpu_sched"                                                                               
kmsg3 "** AArch: $arch"        
kmsg3 "** GPU Load: $gpu_load%"
kmsg3 "** GPU Freq: $gpu_min_clk_mhz-$gpu_max_clk_mhz MHz"
kmsg3 "** GPU Model: $gpu_mdl"                                                                                         
kmsg3 "** GPU Drivers Info: $drvs_info"                                                                                  
kmsg3 "** GPU Governor: $gpu_gov"                                                                                  
kmsg3 "** Device: $dvc_brnd, $dvc_cdn"                                                                                                
kmsg3 "** ROM: $rom_info"                 
kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}')"
kmsg3 "** Screen Density: $(wm density | awk '{print $3}') PPI"
kmsg3 "** Supported Refresh Rates: $rrs HZ"                                                                                                    
kmsg3 "** KTSR Version: $build_ver"                                                                                     
kmsg3 "** KTSR Codename: $build_cdn"                                                                                   
kmsg3 "** Build Type: $build_tp"                                                                                         
kmsg3 "** Build Date: $build_dt"                                                                                          
kmsg3 "** Battery Charge Level: $batt_pctg %"  
kmsg3 "** Battery Capacity: $batt_cpct mAh"
kmsg3 "** Battery Health: $batt_hth"                                                                                     
kmsg3 "** Battery Status: $batt_sts"                                                                                     
kmsg3 "** Battery Temperature: $batt_tmp °C"                                                                               
kmsg3 "** Device RAM: $total_ram MB"                                                                                     
kmsg3 "** Device Available RAM: $avail_ram MB"
kmsg3 "** Root: $root"
kmsg3 "** SQLite Version: $sql_ver"
kmsg3 "** SQLite Build Date: $sql_bd_dt"
kmsg3 "** System Uptime: $sys_uptime"
kmsg3 "** SELinux: $slnx_stt"                                                                                   
kmsg3 "** Busybox: $busy_ver"
kmsg3 ""
kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
kmsg3 "** Telegram Channel: https://t.me/kingprojectz"
kmsg3 "** Telegram Group: https://t.me/kingprojectzdiscussion"
kmsg3 ""

# Disable perf and mpdecision
for v in 0 1 2 3 4; do
    stop vendor.qti.hardware.perf@$v.$v-service 2>/dev/null
    stop perf-hal-$v-$v 2>/dev/null
done

stop perfd 2>/dev/null
stop mpdecision 2>/dev/null
stop vendor.perfservice 2>/dev/null

if [[ -e "/data/system/perfd/default_values" ]]; then
    rm -f "/data/system/perfd/default_values"
fi

kmsg "Disabled perf and mpdecision"
kmsg3 ""

# Configure thermal profile
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "10"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
  if [[ -e "${corectl}/enable" ]]
  then
      write "${corectl}/enable" "0"

  elif [[ -e "${corectl}/disable" ]]
  then
      write "${corectl}/disable" "1"
   fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
    write "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
    write "/sys/power/cpuhotplug/enabled" "0"
fi

if [[ -e "/sys/kernel/intelli_plug" ]]; then
    write "/sys/kernel/intelli_plug/intelli_plug_active" "0"
fi

if [[ -e "/sys/module/blu_plug" ]]; then
    write "/sys/module/blu_plug/parameters/enabled" "0"
fi

if [[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]]; then
    write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
fi

if [[ -e "/sys/module/autosmp" ]]; then
    write "/sys/module/autosmp/parameters/enabled" "0"
fi

if [[ -e "/sys/kernel/zen_decision" ]]; then
    write "/sys/kernel/zen_decision/enabled" "0"
fi

if [[ -e "/proc/hps" ]]; then
    write "/proc/hps/enabled" "0"
fi

kmsg "Disabled core control & CPU hotplug"
kmsg3 ""

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "250"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]
then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "250"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid fiops bfq-sq bfq-mq bfq zen sio anxiety mq-deadline kyber cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
   write "${queue}add_random" 0
   write "${queue}iostats" 0
   write "${queue}rotational" 0
   write "${queue}read_ahead_kb" 512
   write "${queue}nomerges" 2
   write "${queue}rq_affinity" 2
   write "${queue}nr_requests" 256
done

kmsg "Tweaked I/O scheduler"
kmsg3 ""

for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
  write "$governor/up_rate_limit_us" "0"
  write "$governor/down_rate_limit_us" "0"
  write "$governor/pl" "1"
  write "$governor/iowait_boost_enable" "1"
  write "$governor/rate_limit_us" "0"
  write "$governor/hispeed_load" "80"
  write "$governor/hispeed_freq" "$cpu_max_freq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
  write "$governor/timer_rate" "0"
  write "$governor/boost" "1"
  write "$governor/timer_slack" "0"
  write "$governor/input_boost" "1"
  write "$governor/use_migration_notif" "0"
  write "$governor/ignore_hispeed_on_notif" "1"
  write "$governor/use_sched_load" "1"
  write "$governor/fastlane" "1"
  write "$governor/fast_ramp_down" "0"
  write "$governor/sampling_rate" "0"
  write "$governor/sampling_rate_min" "0"
  write "$governor/min_sample_time" "0"
  write "$governor/go_hispeed_load" "80"
  write "$governor/hispeed_freq" "$cpu_max_freq"
done

if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "3"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "1"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "1"
fi

[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "1"

for i in 0 1 2 3 4 5 6 7 8 9
do
  write "/sys/devices/system/cpu/cpu$i/online" "1"
done

kmsg "Tweaked CPU parameters"
kmsg3 ""

if [[ -e "/sys/kernel/hmp" ]]; then
    write "/sys/kernel/hmp/boost" "1"
    write "/sys/kernel/hmp/down_compensation_enabled" "0"
    write "/sys/kernel/hmp/family_boost" "1"
    write "/sys/kernel/hmp/semiboost" "1"
    write "/sys/kernel/hmp/up_threshold" "500"
    write "/sys/kernel/hmp/down_threshold" "180"
    kmsg "Tweaked HMP parameters"
    kmsg3 ""
fi

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/devfreq/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/devfreq/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpui/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Booster Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpui/gpu_governor" "$governor"
			break
		fi
	done

    # Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/available_governors")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/governor" "$governor"
			break
		fi
	done

if [[ $qcom == "true" ]]; then
    write "$gpu/throttling" "0"
    write "$gpu/thermal_pwrlevel" "$gpu_calc_thrtl"
    write "$gpu/devfreq/adrenoboost" "2"
    write "$gpu/force_no_nap" "0"
    write "$gpu/bus_split" "0"
    write "$gpu/devfreq/max_freq" "$gpu_max_freq"
    write "$gpu/devfreq/min_freq" "100000000"
    write "$gpu/default_pwrlevel" "1"
    write "$gpu/force_bus_on" "0"
    write "$gpu/force_clk_on" "0"
    write "$gpu/force_rail_on" "0"
    write "$gpu/idle_timer" "1000"
    write "$gpu/pwrnap" "1"
else
    [[ $one_ui == "false" ]] && write "$gpu/dvfs" "0"
     write "$gpui/gpu_min_clock" "$gpu_min"
     write "$gpu/highspeed_clock" "$gpu_max_freq"
     write "$gpu/highspeed_load" "76"
     write "$gpu/highspeed_delay" "0"
     write "$gpu/power_policy" "coarse_demand"
     write "$gpu/cl_boost_disable" "0"
     write "$gpui/boost" "0"
     write "$gpug/mali_touch_boost_level" "1"
     write "/proc/gpufreq/gpufreq_input_boost" "1"
     write "$gpu/max_freq" "$gpu_max_freq"
     write "$gpu/min_freq" "100000000"
     write "$gpu/tmu" "0"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync "0"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_upthreshold "40"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_downdifferential "20"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold "30"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential "10"
fi

if [[ -d "/sys/modules/ged/" ]]
then
    write "/sys/module/ged/parameters/ged_boost_enable" "1"
    write "/sys/module/ged/parameters/boost_gpu_enable" "1"
    write "/sys/module/ged/parameters/boost_extra" "1"
    write "/sys/module/ged/parameters/enable_cpu_boost" "1"
    write "/sys/module/ged/parameters/enable_gpu_boost" "1"
    write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
    write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
    write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
    write "/sys/module/ged/parameters/ged_smart_boost" "0"
    write "/sys/module/ged/parameters/gpu_debug_enable" "0"
    write "/sys/module/ged/parameters/gpu_dvfs_enable" "0"
    write "/sys/module/ged/parameters/gx_3D_benchmark_on" "1"
    write "/sys/module/ged/parameters/gx_dfps" "1"
    write "/sys/module/ged/parameters/gx_force_cpu_boost" "1"
    write "/sys/module/ged/parameters/gx_frc_mode" "1"
    write "/sys/module/ged/parameters/gx_game_mode" "0"
    write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
fi

if [[ -d "/proc/gpufreq/" ]] 
then
    write "/proc/gpufreq/gpufreq_opp_freq" "$gpu_max3"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
fi

# Tweak some mali parameters
if [[ -d "/proc/mali/" ]] 
then
     [[ $one_ui == "false" ]] && write "/proc/mali/dvfs_enable" "0"
     write "/proc/mali/always_on" "0"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "0"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
    write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "Y"
fi

kmsg "Tweaked GPU parameters"
kmsg3 ""

if [[ -e "/sys/module/cryptomgr/parameters/notests" ]]
then
    write "/sys/module/cryptomgr/parameters/notests" "Y"
    kmsg "Disabled forced cryptography tests"
    kmsg3 ""
fi

# Disable adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
    write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
    kmsg "Disabled adreno idler"
    kmsg3 ""
fi

# Schedtune Tweaks
if [[ -d "$stune" ]]
then
    write "${stune}background/schedtune.boost" "0"
    write "${stune}background/schedtune.prefer_idle" "0"
    write "${stune}background/schedtune.sched_boost" "0"
    write "${stune}background/schedtune.prefer_perf" "0"

    write "${stune}foreground/schedtune.boost" "50"
    write "${stune}foreground/schedtune.prefer_idle" "1"
    write "${stune}foreground/schedtune.sched_boost" "15"
    write "${stune}foreground/schedtune.sched_boost_no_override" "1"
    write "${stune}foreground/schedtune.prefer_perf" "1"

    write "${stune}rt/schedtune.boost" "0"
    write "${stune}rt/schedtune.prefer_idle" "0"
    write "${stune}rt/schedtune.sched_boost" "0"
    write "${stune}rt/schedtune.prefer_perf" "0"

    write "${stune}top-app/schedtune.boost" "50"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "15"
    write "${stune}top-app/schedtune.sched_boost_no_override" "1"
    write "${stune}top-app/schedtune.prefer_perf" "1"

    write "${stune}schedtune.boost" "0"
    write "${stune}schedtune.prefer_idle" "0"
    kmsg "Tweaked cpuset schedtune"
    kmsg3 ""
fi

# Uclamp Tweaks
if [[ -e "${cpuset}top-app/uclamp.max" ]]
then
    sysctl -w kernel.sched_util_clamp_min_rt_default=96
    sysctl -w kernel.sched_util_clamp_min=192

    write "${cpuset}top-app/uclamp.max" "max"
    write "${cpuset}top-app/uclamp.min" "max"
    write "${cpuset}top-app/uclamp.boosted" "1"
    write "${cpuset}top-app/uclamp.latency_sensitive" "1"

    write "${cpuset}foreground/uclamp.max" "max"
    write "${cpuset}foreground/uclamp.min" "max"
    write "${cpuset}foreground/uclamp.boosted" "1"
    write "${cpuset}foreground/uclamp.latency_sensitive" "1"

    write "${cpuset}background/uclamp.max" "50"
    write "${cpuset}background/uclamp.min" "0"
    write "${cpuset}background/uclamp.boosted" "0"
    write "${cpuset}background/uclamp.latency_sensitive" "0"

    write "${cpuset}system-background/uclamp.max" "40"
    write "${cpuset}system-background/uclamp.min" "0"
    write "${cpuset}system-background/uclamp.boosted" "0"
    write "${cpuset}system-background/uclamp.latency_sensitive" "0"
    kmsg "Tweaked cpuset uclamp"
    kmsg3 ""
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
    write "/proc/sys/fs/dir-notify-enable" "0"
    write "/proc/sys/fs/lease-break-time" "10"
    write "/proc/sys/fs/leases-enable" "1"
    write "/proc/sys/fs/inotify/max_queued_events" "131072"
    write "/proc/sys/fs/inotify/max_user_watches" "131072"
    write "/proc/sys/fs/inotify/max_user_instances" "1024"
    kmsg "Tweaked FS"
    kmsg3 ""
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
    write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
    kmsg "Enabled dynamic fsync"
    kmsg3 ""
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    write "/sys/kernel/debug/sched_features" "UTIL_EST"
    [[ $cpu_sched == "EAS" ]] && write "/sys/kernel/debug/sched_features" "EAS_PREFER_IDLE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi

if [[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]]; then
    write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
    kmsg "Disabled MMC CRC"
    kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/removable" ]]; then
      write "/sys/module/mmc_core/parameters/removable" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/crc" ]]; then
      write "/sys/module/mmc_core/parameters/crc" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""
fi

# Tweak some kernel settings to improve overall performance.
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "0"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "25"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkscale_enable" ]]; then
    write "/sys/devices/soc/$dv/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkgate_enable" ]]; then
    write "/sys/devices/soc/$dv/clkgate_enable" "0"
fi
write "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "5000000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "128"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    write "${kernel}sched_boost" "2"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]] && [[ "$mtk" == "true" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "2"
else
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "/proc/ufs_perf" ]]; then
    write "/proc/ufs_perf" "2"
fi
if [[ -e "/proc/cpuidle/enable" ]]; then
    write "/proc/cpuidle/enable" "0"
fi
if [[ -e "/sys/kernel/debug/eara_thermal/enable" ]]; then
    write "/sys/kernel/debug/eara_thermal/enable" "0"
fi

# Enable UTW (UFS Turbo Write)
for ufs in /sys/devices/platform/soc/*.ufshc/ufstw_lu*; do
   if [[ -d "$ufs" ]]; then
       write "${ufs}tw_enable" "1"
       kmsg "Enabled UFS Turbo Write"
       kmsg3 ""
     fi
  break
done

if [[ -e "/sys/power/little_thermal_temp" ]]; then
    write "/sys/power/little_thermal_temp" "90"
fi

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy_status" "1 0"
    write "/proc/ppm/policy_status" "2 1"
    write "/proc/ppm/policy_status" "3 0"
    write "/proc/ppm/policy_status" "4 0"
    write "/proc/ppm/policy_status" "7 0"
    write "/proc/ppm/policy_status" "9 1"
fi

kmsg "Tweaked various kernel parameters"
kmsg3 ""

# Enable fingerprint boost
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
    write "/sys/kernel/fp_boost/enabled" "1"
    kmsg "Enabled fingerprint_boost"
    kmsg3 ""
fi

if [[ "$ppm" == "true" ]]; then
write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_max_freq"
write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_max_freq"
write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
fi

# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_max_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_max_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

kmsg "Tweaked CPU clocks"
kmsg3 ""

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
    write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
    kmsg "Allowed CPUs to use it's deepest sleep state"
    kmsg3 ""
fi

# Enable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
    write "/sys/module/acpuclock_krait/parameters/boost" "Y"
    kmsg "Enabled krait voltage boost"
    kmsg3 ""
fi

fr=$(((total_ram * 3 / 2 / 100) * 1024 / 4))
bg=$(((total_ram * 3 / 100) * 1024 / 4))
et=$(((total_ram * 5 / 100) * 1024 / 4))
mr=$(((total_ram * 7 / 100) * 1024 / 4))
cd=$(((total_ram * 11 / 100) * 1024 / 4))
ab=$(((total_ram * 14 / 100) * 1024 / 4))

efr=$((mfr * 16 / 5))

if [[ "$efr" -le "18432" ]]; then
    efr=18432
fi

mfr=$((total_ram * 6 / 5))

if [[ "$mfr" -le "3072" ]]; then
    mfr=3072
fi

# always sync before dropping caches
sync

# VM settings to improve overall user experience and performance.
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "10"
write "${vm}dirty_ratio" "30"
write "${vm}dirty_expire_centisecs" "1000"
write "${vm}dirty_writeback_centisecs" "1000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Use SSWAP defaults if device haven't more than 3 GB RAM on exynos SOC's
if [[ $exynos == "true" ]] && [[ $total_ram -lt "3000" ]]; then
    write "${vm}swappiness" "150"
else
    write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "150"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]] | [[ $total_ram -lt "5000" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
write "${vm}reap_mem_on_sigkill" "1"

# Tune lmk_minfree
if [[ -e "${lmk}/parameters/minfree" ]]; then
    write "${lmk}/parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

# Enable oom_reaper
if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
# Enable lmk_fast_run
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

# Disable adaptive_lmk
if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

# Tune vm_min_free_kbytes
if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
# Tune vm_extra_free_kbytes
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
    write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
    write "/sys/module/msm_thermal/core_control/enabled" "0"
    write "/sys/module/msm_thermal/parameters/enabled" "N"
    kmsg "Tweaked msm_thermal"
    kmsg3 ""
fi

# Disable CPU power efficient workqueue
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
    write "/sys/module/workqueue/parameters/power_efficient" "N" 
    kmsg "Disabled CPU power efficient workqueue"
    kmsg3 ""
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
    kmsg "Disabled CPU scheduler multi-core power-saving"
    kmsg3 ""
fi

# Fix DT2W
if [[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]]
then
    write "/sys/touchpanel/double_tap" "1"
    write "/proc/tp_gesture" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/class/sec/tsp/dt2w_enable" ]]
then
    write "/sys/class/sec/tsp/dt2w_enable" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/proc/tp_gesture" ]]
then
    write "/proc/tp_gesture" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
     write "/sys/touchpanel/double_tap" "1"
     kmsg "Fixed DT2W if broken"
     kmsg3 ""
fi

# Enable touch boost on gaming and performance profile.
if [[ -e "/sys/module/msm_performance/parameters/touchboost" ]]
then
    write "/sys/module/msm_performance/parameters/touchboost" "1"
    kmsg "Enabled msm_performance touch boost"
    kmsg3 ""

elif [[ -e "/sys/power/pnpmgr/touch_boost" ]]
then
    write "/sys/power/pnpmgr/touch_boost" "1"
    write "/sys/power/pnpmgr/long_duration_touch_boost" "1"
    kmsg "Enabled pnpmgr touch boost"
    kmsg3 ""
fi

# Fetch the available TCP congestion control 
avail_con="$(cat "${tcp}tcp_available_congestion_control")"
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr westwood cubic 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# TCP Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg "Applied TCP tweaks"
kmsg3 ""

# Disable kernel battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
    write "/sys/module/battery_saver/parameters/enabled" "N"
    kmsg "Disabled kernel battery saver"
    kmsg3 ""
fi

# Enable high performance audio
for hpm in /sys/module/snd_soc_wcd*
do
  if [[ -e "$hpm" ]]
  then
      write "${hpm}/parameters/high_perf_mode" "1"
      kmsg "Enabled high performance audio"
      kmsg3 ""
      break
   fi
done

# Disable LPM in extreme / gaming profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
  if [[ -d "/sys/module/lpm_levels" ]]
  then
      write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
      write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
      write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
      write "${lpm}idle_enabled" "N"
      write "${lpm}suspend_enabled" "N"
   fi
done

kmsg "Disabled LPM"
kmsg3 ""

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]] 
then
    write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
    kmsg "Disabled pm2 idle sleep mode"
    kmsg3 ""
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
    write "/sys/class/lcd/panel/power_reduce" "0"
    kmsg "Disabled LCD power reduce"
    kmsg3 ""
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
    write "/sys/kernel/fast_charge/force_fast_charge" "1"
    kmsg "Enabled USB 3.0 fast charging"
    kmsg3 ""
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
    write "/sys/class/sec/switch/afc_disable" "0"
    kmsg "Enabled fast charging on Samsung devices"
    kmsg3 ""
fi
  
kmsg "Extreme profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exectime=$((exit - init))
kmsg "Elapsed time: $exectime seconds."
}
# Battery Profile
battery() {
init=$(date +%s)
   
get_all
  	
kmsg3 ""  	
kmsg "General Info"

kmsg3 ""
kmsg3 "** Date of execution: $(date)"                                                                                    
kmsg3 "** Kernel: $kern_ver_name"                                                                                           
kmsg3 "** Kernel Build Date: $kern_bd_dt"
kmsg3 "** SOC: $soc_mf, $soc"                                                                                               
kmsg3 "** SDK: $sdk"
kmsg3 "** Android Version: $avs"    
kmsg3 "** CPU Governor: $cpu_gov"   
kmsg3 "** CPU Load: $cpu_load %"
kmsg3 "** Number of cores: $nr_cores"
kmsg3 "** CPU Freq: $cpu_min_clk_mhz-$cpu_max_clk_mhz MHz"
kmsg3 "** CPU Scheduling Type: $cpu_sched"                                                                               
kmsg3 "** AArch: $arch"        
kmsg3 "** GPU Load: $gpu_load%"
kmsg3 "** GPU Freq: $gpu_min_clk_mhz-$gpu_max_clk_mhz MHz"
kmsg3 "** GPU Model: $gpu_mdl"                                                                                         
kmsg3 "** GPU Drivers Info: $drvs_info"                                                                                  
kmsg3 "** GPU Governor: $gpu_gov"                                                                                  
kmsg3 "** Device: $dvc_brnd, $dvc_cdn"                                                                                                
kmsg3 "** ROM: $rom_info"                 
kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}')"
kmsg3 "** Screen Density: $(wm density | awk '{print $3}') PPI"
kmsg3 "** Supported Refresh Rates: $rrs HZ"                                                                                                    
kmsg3 "** KTSR Version: $build_ver"                                                                                     
kmsg3 "** KTSR Codename: $build_cdn"                                                                                   
kmsg3 "** Build Type: $build_tp"                                                                                         
kmsg3 "** Build Date: $build_dt"                                                                                          
kmsg3 "** Battery Charge Level: $batt_pctg %"  
kmsg3 "** Battery Capacity: $batt_cpct mAh"
kmsg3 "** Battery Health: $batt_hth"                                                                                     
kmsg3 "** Battery Status: $batt_sts"                                                                                     
kmsg3 "** Battery Temperature: $batt_tmp °C"                                                                               
kmsg3 "** Device RAM: $total_ram MB"                                                                                     
kmsg3 "** Device Available RAM: $avail_ram MB"
kmsg3 "** Root: $root"
kmsg3 "** SQLite Version: $sql_ver"
kmsg3 "** SQLite Build Date: $sql_bd_dt"
kmsg3 "** System Uptime: $sys_uptime"
kmsg3 "** SELinux: $slnx_stt"                                                                                   
kmsg3 "** Busybox: $busy_ver"
kmsg3 ""
kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
kmsg3 "** Telegram Channel: https://t.me/kingprojectz"
kmsg3 "** Telegram Group: https://t.me/kingprojectzdiscussion"
kmsg3 ""

# Disable perf and mpdecision
for v in 0 1 2 3 4; do
    stop vendor.qti.hardware.perf@$v.$v-service 2>/dev/null
    stop perf-hal-$v-$v 2>/dev/null
done

stop perfd 2>/dev/null
stop mpdecision 2>/dev/null
stop vendor.perfservice 2>/dev/null

if [[ -e "/data/system/perfd/default_values" ]]; then
    rm -f "/data/system/perfd/default_values"
fi

kmsg "Disabled perf and mpdecision"
kmsg3 ""

# Configure thermal profile
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "0"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "10"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
  if [[ -e "${corectl}/enable" ]]
  then
      write "${corectl}/enable" "0"

  elif [[ -e "${corectl}/disable" ]]
  then
      write "${corectl}/disable" "1"
   fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
    write "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
    write "/sys/power/cpuhotplug/enabled" "0"
fi

if [[ -e "/sys/kernel/intelli_plug" ]]; then
    write "/sys/kernel/intelli_plug/intelli_plug_active" "0"
fi

if [[ -e "/sys/module/blu_plug" ]]; then
    write "/sys/module/blu_plug/parameters/enabled" "0"
fi

if [[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]]; then
    write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
fi

if [[ -e "/sys/module/autosmp" ]]; then
    write "/sys/module/autosmp/parameters/enabled" "0"
fi

if [[ -e "/sys/kernel/zen_decision" ]]; then
    write "/sys/kernel/zen_decision/enabled" "0"
fi

if [[ -e "/proc/hps" ]]; then
    write "/proc/hps/enabled" "1"
fi

kmsg "Disabled core control and CPU hotplug"
kmsg3 ""

# Caf CPU Boost
if [[ -e "/sys/module/cpu_boost/parameters/input_boost_ms" ]]
then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "64"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""
fi

# CPU input boost
if [[ -e "/sys/module/cpu_input_boost/parameters/input_boost_duration" ]]
then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "64"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid fiops bfq-sq bfq-mq bfq zen sio anxiety mq-deadline kyber cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
   write "${queue}add_random" 0
   write "${queue}iostats" 0
   write "${queue}rotational" 0
   write "${queue}read_ahead_kb" 64
   write "${queue}nomerges" 0
   write "${queue}rq_affinity" 0
   write "${queue}nr_requests" 512
done

kmsg "Tweaked I/O scheduler"
kmsg3 ""

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
  write "$governor/up_rate_limit_us" "50000"
  write "$governor/down_rate_limit_us" "24000"
  write "$governor/pl" "1"
  write "$governor/iowait_boost_enable" "1"
  write "$governor/rate_limit_us" "50000"
  write "$governor/hispeed_load" "99"
  write "$governor/hispeed_freq" "$cpu_max_freq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
  write "$governor/timer_rate" "50000"
  write "$governor/boost" "0"
  write "$governor/timer_slack" "50000"
  write "$governor/input_boost" "0"
  write "$governor/use_migration_notif" "0" 
  write "$governor/ignore_hispeed_on_notif" "1"
  write "$governor/use_sched_load" "1"
  write "$governor/boostpulse" "0"
  write "$governor/fastlane" "1"
  write "$governor/fast_ramp_down" "1"
  write "$governor/sampling_rate" "50000"
  write "$governor/sampling_rate_min" "50000"
  write "$governor/min_sample_time" "50000"
  write "$governor/go_hispeed_load" "99"
  write "$governor/hispeed_freq" "$cpu_max_freq"
done

if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]]; then
    write "/proc/cpufreq/cpufreq_power_mode" "1"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "0"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "0"
fi

[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "1"

for i in 0 1 2 3 4 5 6 7 8 9
do
  write "/sys/devices/system/cpu/cpu$i/online" "1"
done

kmsg "Tweaked CPU parameters"
kmsg3 ""

if [[ -e "/sys/kernel/hmp" ]]; then
    write "/sys/kernel/hmp/boost" "0"
    write "/sys/kernel/hmp/down_compensation_enabled" "1"
    write "/sys/kernel/hmp/family_boost" "0"
    write "/sys/kernel/hmp/semiboost" "0"
    write "/sys/kernel/hmp/up_threshold" "789"
    write "/sys/kernel/hmp/down_threshold" "303"
    kmsg "Tweaked HMP parameters"
    kmsg3 ""
fi

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/devfreq/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/devfreq/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpui/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Interactive Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpui/gpu_governor" "$governor"
			break
		fi
	done

    # Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/available_governors")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/governor" "$governor"
			break
		fi
	done

if [[ $qcom == "true" ]]; then
    write "$gpu/throttling" "1"
    write "$gpu/thermal_pwrlevel" "$gpu_calc_thrtl"
    write "$gpu/devfreq/adrenoboost" "0"
    write "$gpu/force_no_nap" "0"
    write "$gpu/bus_split" "1"
    write "$gpu/devfreq/min_freq" "100000000"
    write "$gpu/default_pwrlevel" "$gpu_min_pl"
    write "$gpu/force_bus_on" "0"
    write "$gpu/force_clk_on" "0"
    write "$gpu/force_rail_on" "0"
    write "$gpu/idle_timer" "39"
    write "$gpu/pwrnap" "1"
else
    [[ $one_ui == "false" ]] && write "$gpu/dvfs" "1"
     write "$gpui/gpu_min_clock" "$gpu_min"
     write "$gpu/highspeed_clock" "$gpu_max_freq"
     write "$gpu/highspeed_load" "95"
     write "$gpu/highspeed_delay" "0"
     write "$gpu/power_policy" "coarse_demand"
     write "$gpu/cl_boost_disable" "1"
     write "$gpui/boost" "0"
     write "$gpug/mali_touch_boost_level" "0"
     write "/proc/gpufreq/gpufreq_input_boost" "0"
     write "$gpu/max_freq" "$gpu_max_freq"
     write "$gpu/min_freq" "100000000"
     write "$gpu/tmu" "1"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync "1"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_upthreshold "85"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_downdifferential "65"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold "75"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential "55"
fi

if [[ -d "/sys/modules/ged/" ]]
then
    write "/sys/module/ged/parameters/ged_boost_enable" "0"
    write "/sys/module/ged/parameters/boost_gpu_enable" "0"
    write "/sys/module/ged/parameters/boost_extra" "0"
    write "/sys/module/ged/parameters/enable_cpu_boost" "0"
    write "/sys/module/ged/parameters/enable_gpu_boost" "0"
    write "/sys/module/ged/parameters/enable_game_self_frc_detect" "0"
    write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
    write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
    write "/sys/module/ged/parameters/ged_smart_boost" "0"
    write "/sys/module/ged/parameters/gpu_debug_enable" "0"
    write "/sys/module/ged/parameters/gpu_dvfs_enable" "1"
    write "/sys/module/ged/parameters/gx_3D_benchmark_on" "0"
    write "/sys/module/ged/parameters/gx_dfps" "0"
    write "/sys/module/ged/parameters/gx_force_cpu_boost" "0"
    write "/sys/module/ged/parameters/gx_frc_mode" "0"
    write "/sys/module/ged/parameters/gx_game_mode" "0"
    write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
fi

if [[ -d "/proc/gpufreq/" ]] 
then
    write "/proc/gpufreq/gpufreq_opp_freq" "0"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "0"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "0"
fi

# Tweak some mali parameters
if [[ -d "/proc/mali/" ]] 
then
     [[ $one_ui == "false" ]] && write "/proc/mali/dvfs_enable" "1"
     write "/proc/mali/always_on" "0"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "1"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
    write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "Y"
fi

kmsg "Tweaked GPU parameters"
kmsg3 ""

if [[ -e "/sys/module/cryptomgr/parameters/notests" ]]
then
    write "/sys/module/cryptomgr/parameters/notests" "Y"
    kmsg "Disabled forced cryptography tests"
    kmsg3 ""
fi

# Enable and tweak adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
    write "/sys/module/adreno_idler/parameters/adreno_idler_active" "Y"
    write "/sys/module/adreno_idler/parameters/adreno_idler_idleworkload" "10000"
    write "/sys/module/adreno_idler/parameters/adreno_idler_downdifferential" "45"
    write "/sys/module/adreno_idler/parameters/adreno_idler_idlewait" "15"
    kmsg "Enabled and tweaked adreno idler"
    kmsg3 ""
fi

# Schedtune tweaks
if [[ -d "$stune" ]]
then
    write "${stune}background/schedtune.boost" "0"
    write "${stune}background/schedtune.prefer_idle" "0"
    write "${stune}background/schedtune.sched_boost" "0"
    write "${stune}background/schedtune.prefer_perf" "0"

    write "${stune}foreground/schedtune.boost" "0"
    write "${stune}foreground/schedtune.prefer_idle" "0"
    write "${stune}foreground/schedtune.sched_boost" "0"
    write "${stune}foreground/schedtune.prefer_perf" "0"

    write "${stune}rt/schedtune.boost" "0"
    write "${stune}rt/schedtune.prefer_idle" "0"
    write "${stune}rt/schedtune.sched_boost" "0"
    write "${stune}rt/schedtune.prefer_perf" "0"

    write "${stune}top-app/schedtune.boost" "10"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "0"
    write "${stune}top-app/schedtune.sched_boost_no_override" "1"
    write "${stune}top-app/schedtune.prefer_perf" "1"

    write "${stune}schedtune.boost" "0"
    write "${stune}schedtune.prefer_idle" "0"
    kmsg "Tweaked cpuset schedtune"
    kmsg3 ""
fi

# Uclamp Tweaks
if [[ -e "${cpuset}top-app/uclamp.max" ]]
then
    sysctl -w kernel.sched_util_clamp_min_rt_default=16
    sysctl -w kernel.sched_util_clamp_min=128

    write "${cpuset}top-app/uclamp.max" "max"
    write "${cpuset}top-app/uclamp.min" "5"
    write "${cpuset}top-app/uclamp.boosted" "1"
    write "${cpuset}top-app/uclamp.latency_sensitive" "1"

    write "${cpuset}foreground/uclamp.max" "max"
    write "${cpuset}foreground/uclamp.min" "0"
    write "${cpuset}foreground/uclamp.boosted" "0"
    write "${cpuset}foreground/uclamp.latency_sensitive" "0"

    write "${cpuset}background/uclamp.max" "50"
    write "${cpuset}background/uclamp.min" "0"
    write "${cpuset}background/uclamp.boosted" "0"
    write "${cpuset}background/uclamp.latency_sensitive" "0"

    write "${cpuset}system-background/uclamp.max" "40"
    write "${cpuset}system-background/uclamp.min" "0"
    write "${cpuset}system-background/uclamp.boosted" "0"
    write "${cpuset}system-background/uclamp.latency_sensitive" "0"
    kmsg "Tweaked cpuset uclamp"
    kmsg3 ""
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
    write "/proc/sys/fs/dir-notify-enable" "0"
    write "/proc/sys/fs/lease-break-time" "10"
    write "/proc/sys/fs/leases-enable" "1"
    write "/proc/sys/fs/inotify/max_queued_events" "131072"
    write "/proc/sys/fs/inotify/max_user_watches" "131072"
    write "/proc/sys/fs/inotify/max_user_instances" "1024"
    kmsg "Tweaked FS"
    kmsg3 ""
fi
    
# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
    write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
    kmsg "Enabled dynamic fsync"
    kmsg3 ""
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "NO_TTWU_QUEUE"
    write "/sys/kernel/debug/sched_features" "UTIL_EST"
    [[ $cpu_sched == "EAS" ]] && write "/sys/kernel/debug/sched_features" "EAS_PREFER_IDLE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi

if [[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]]; then
    write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
    kmsg "Disabled MMC CRC"
    kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/removable" ]]; then
      write "/sys/module/mmc_core/parameters/removable" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/crc" ]]; then
      write "/sys/module/mmc_core/parameters/crc" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""
fi

# Tweak some kernel settings to improve overall performance.
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "0"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "3"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "1"
fi
if [[ -e "/sys/devices/soc/$dv/clkscale_enable" ]]; then
    write "/sys/devices/soc/$dv/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkgate_enable" ]]; then
    write "/sys/devices/soc/$dv/clkgate_enable" "1"
fi
write "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "$SCHED_PERIOD_BATTERY"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_BATTERY / SCHED_TASKS_BATTERY))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_BATTERY / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "5000000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "192"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "1"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    write "${kernel}sched_boost" "0"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "/proc/ufs_perf" ]]; then
    write "/proc/ufs_perf" "0"
fi
if [[ -e "/proc/cpuidle/enable" ]]; then
    write "/proc/cpuidle/enable" "1"
fi
if [[ -e "/sys/kernel/debug/eara_thermal/enable" ]]; then
    write "/sys/kernel/debug/eara_thermal/enable" "0"
fi

# Disable UTW (UFS Turbo Write)
for ufs in /sys/devices/platform/soc/*.ufshc/ufstw_lu*; do
   if [[ -d "$ufs" ]]; then
       write "${ufs}tw_enable" "0"
       kmsg "Disabled UFS Turbo Write"
       kmsg3 ""
     fi
  break
done

if [[ -e "/sys/power/little_thermal_temp" ]]; then
    write "/sys/power/little_thermal_temp" "90"
fi

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy_status" "1 0"
    write "/proc/ppm/policy_status" "2 0"
    write "/proc/ppm/policy_status" "3 0"
    write "/proc/ppm/policy_status" "4 1"
    write "/proc/ppm/policy_status" "7 0"
    write "/proc/ppm/policy_status" "9 0"
fi

kmsg "Tweaked various kernel parameters"
kmsg3 ""

# Disable fingerprint boost
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
    write "/sys/kernel/fp_boost/enabled" "0"
    kmsg "Disabled fingerprint boost"
    kmsg3 ""
fi

if [[ "$ppm" == "true" ]]; then
    write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "0 $cpu_min_freq"
    write "/proc/ppm/policy/hard_userlimit_min_cpu_freq" "1 $cpu_min_freq"
    write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "0 $cpu_max_freq"
    write "/proc/ppm/policy/hard_userlimit_max_cpu_freq" "1 $cpu_max_freq"
fi

# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_min_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

kmsg "Tweaked CPU clocks"
kmsg3 ""

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
    write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "1"
    kmsg "Allowed CPUs to use it's deepest sleep state"
    kmsg3 ""
fi

# Disable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
    write "/sys/module/acpuclock_krait/parameters/boost" "N"
    kmsg "Disabled krait voltage boost"
    kmsg3 ""
fi

fr=$(((total_ram * 2 / 100) * 1024 / 4))
bg=$(((total_ram * 3 / 100) * 1024 / 4))
et=$(((total_ram * 4 / 100) * 1024 / 4))
mr=$(((total_ram * 8 / 100) * 1024 / 4))
cd=$(((total_ram * 12 / 100) * 1024 / 4))
ab=$(((total_ram * 14 / 100) * 1024 / 4))

efr=$((mfr * 16 / 5))

if [[ "$efr" -le "18432" ]]; then
    efr=18432
fi

mfr=$((total_ram * 7 / 5))

if [[ "$mfr" -le "3072" ]]; then
    mfr=3072
fi

# always sync before dropping caches
sync

# VM settings to improve overall user experience and performance.
write "${vm}drop_caches" "1"
write "${vm}dirty_background_ratio" "5"
write "${vm}dirty_ratio" "20"
write "${vm}dirty_expire_centisecs" "200"
write "${vm}dirty_writeback_centisecs" "500"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Use SSWAP if device haven't more than 3 GB RAM
if [[ $exynos == "true" ]] && [[ $total_ram -lt "3000" ]]; then
    write "${vm}swappiness" "150"
else
    write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "60"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]] | [[ $total_ram -lt "5000" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
write "${vm}reap_mem_on_sigkill" "1"

# Tune lmk_minfree
if [[ -e "${lmk}/parameters/minfree" ]]; then
    write "${lmk}/parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

# Enable oom_reaper
if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
# Enable lmk_fast_run
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

# Disable adaptive_lmk
if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "0"
fi

# Tune vm_min_free_kbytes
if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
# Tune vm_extra_free_kbytes
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
    write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
    write "/sys/module/msm_thermal/core_control/enabled" "0"
    write "/sys/module/msm_thermal/parameters/enabled" "N"
    kmsg "Tweaked msm_thermal"
    kmsg3 ""
fi

# Enable power efficient workqueue.
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
    write "/sys/module/workqueue/parameters/power_efficient" "Y"
    kmsg "Enabled CPU power efficient workqueue"
    kmsg3 ""
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "2"
    kmsg "Enabled CPU multi-core power-saving"
    kmsg3 ""
fi

# Fix DT2W
if [[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]]
then
    write "/sys/touchpanel/double_tap" "1"
    write "/proc/tp_gesture" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/class/sec/tsp/dt2w_enable" ]]
then
    write "/sys/class/sec/tsp/dt2w_enable" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/proc/tp_gesture" ]]
then
    write "/proc/tp_gesture" "1"
    kmsg "Fixed DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
     write "/sys/touchpanel/double_tap" "1"
     kmsg "Fixed DT2W if broken"
     kmsg3 ""
fi

# Disable touch boost on battery and balance profile.
if [[ -e "/sys/module/msm_performance/parameters/touchboost" ]]
then
    write "/sys/module/msm_performance/parameters/touchboost" "0"
    kmsg "Disabled msm_performance touch boost"
    kmsg3 ""

elif [[ -e "/sys/power/pnpmgr/touch_boost" ]]
then
    write "/sys/power/pnpmgr/touch_boost" "0"
    write "/sys/power/pnpmgr/long_duration_touch_boost" "0"
    kmsg "Disabled pnpmgr touch boost"
    kmsg3 ""
fi

# Fetch the available TCP congestion control 
avail_con="$(cat "${tcp}tcp_available_congestion_control")"
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr westwood cubic 
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# TCP Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg "Applied TCP tweaks"
kmsg3 ""

# Enable kernel battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
    write "/sys/module/battery_saver/parameters/enabled" "Y"
    kmsg "Enabled kernel battery saver"
    kmsg3 ""
fi

# Disable high performance audio
for hpm in /sys/module/snd_soc_wcd*
do
  if [[ -e "$hpm" ]]
  then
      write "${hpm}/parameters/high_perf_mode" "0"
      kmsg "Disabled high performance audio"
      kmsg3 ""
      break
   fi
done

# Enable LPM in balanced / battery profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
  if [[ -d "/sys/module/lpm_levels" ]]
  then
      write "/sys/module/lpm_levels/parameters/lpm_prediction" "Y"
      write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "Y"
      write "/sys/module/lpm_levels/parameters/sleep_disabled" "N"
      write "${lpm}idle_enabled" "Y"
      write "${lpm}suspend_enabled" "Y"
   fi
done

kmsg "Enabled LPM"
kmsg3 ""

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
write "/sys/class/lcd/panel/power_reduce" "1"
kmsg "Enabled LCD power reduce"
kmsg3 ""
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
    write "/sys/kernel/fast_charge/force_fast_charge" "1"
    kmsg "Enabled USB 3.0 fast charging"
    kmsg3 ""
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
    write "/sys/class/sec/switch/afc_disable" "0"
    kmsg "Enabled fast charging on Samsung devices"
    kmsg3 ""
fi
  
kmsg "Battery profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exectime=$((exit - init))
kmsg "Elapsed time: $exectime seconds."
}
# Gaming Profile
gaming() {
init=$(date +%s)
     	
get_all

kmsg3 ""  	
kmsg "General Info"

kmsg3 ""
kmsg3 "** Date of execution: $(date)"                                                                                    
kmsg3 "** Kernel: $kern_ver_name"                                                                                           
kmsg3 "** Kernel Build Date: $kern_bd_dt"
kmsg3 "** SOC: $soc_mf, $soc"                                                                                               
kmsg3 "** SDK: $sdk"
kmsg3 "** Android Version: $avs"    
kmsg3 "** CPU Governor: $cpu_gov"   
kmsg3 "** CPU Load: $cpu_load %"
kmsg3 "** Number of cores: $nr_cores"
kmsg3 "** CPU Freq: $cpu_min_clk_mhz-$cpu_max_clk_mhz MHz"
kmsg3 "** CPU Scheduling Type: $cpu_sched"                                                                               
kmsg3 "** AArch: $arch"        
kmsg3 "** GPU Load: $gpu_load%"
kmsg3 "** GPU Freq: $gpu_min_clk_mhz-$gpu_max_clk_mhz MHz"
kmsg3 "** GPU Model: $gpu_mdl"                                                                                         
kmsg3 "** GPU Drivers Info: $drvs_info"                                                                                  
kmsg3 "** GPU Governor: $gpu_gov"                                                                                  
kmsg3 "** Device: $dvc_brnd, $dvc_cdn"                                                                                                
kmsg3 "** ROM: $rom_info"                 
kmsg3 "** Screen Resolution: $(wm size | awk '{print $3}')"
kmsg3 "** Screen Density: $(wm density | awk '{print $3}') PPI"
kmsg3 "** Supported Refresh Rates: $rrs HZ"                                                                                                    
kmsg3 "** KTSR Version: $build_ver"                                                                                     
kmsg3 "** KTSR Codename: $build_cdn"                                                                                   
kmsg3 "** Build Type: $build_tp"                                                                                         
kmsg3 "** Build Date: $build_dt"                                                                                          
kmsg3 "** Battery Charge Level: $batt_pctg %"  
kmsg3 "** Battery Capacity: $batt_cpct mAh"
kmsg3 "** Battery Health: $batt_hth"                                                                                     
kmsg3 "** Battery Status: $batt_sts"                                                                                     
kmsg3 "** Battery Temperature: $batt_tmp °C"                                                                               
kmsg3 "** Device RAM: $total_ram MB"                                                                                     
kmsg3 "** Device Available RAM: $avail_ram MB"
kmsg3 "** Root: $root"
kmsg3 "** SQLite Version: $sql_ver"
kmsg3 "** SQLite Build Date: $sql_bd_dt"
kmsg3 "** System Uptime: $sys_uptime"
kmsg3 "** SELinux: $slnx_stt"                                                                                   
kmsg3 "** Busybox: $busy_ver"
kmsg3 ""
kmsg3 "** Author: Pedro | https://t.me/pedro3z0 | https://github.com/pedrozzz0"
kmsg3 "** Telegram Channel: https://t.me/kingprojectz"
kmsg3 "** Telegram Group: https://t.me/kingprojectzdiscussion"
kmsg3 ""

# Disable perf and mpdecision
for v in 0 1 2 3 4; do
    stop vendor.qti.hardware.perf@$v.$v-service 2>/dev/null
    stop perf-hal-$v-$v 2>/dev/null
done

stop perfd 2>/dev/null
stop mpdecision 2>/dev/null
stop vendor.perfservice 2>/dev/null

if [[ -e "/data/system/perfd/default_values" ]]; then
    rm -f "/data/system/perfd/default_values"
fi

kmsg "Disabled perf and mpdecision"
kmsg3 ""

# Configure thermal profile to dynamic (evaluation)
if [[ -e "/sys/class/thermal/thermal_message" ]]; then
    write "/sys/class/thermal/thermal_message/sconfig" "10"
    kmsg "Tweaked thermal profile"
    kmsg3 ""
fi

if [[ -e "/sys/module/cpu_boost/parameters/dynamic_stune_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost" "50"
    write "/sys/module/cpu_boost/parameters/dynamic_stune_boost_ms" "1000"
    kmsg "Tweaked dynamic stune boost"
    kmsg3 ""
fi

for corectl in /sys/devices/system/cpu/cpu*/core_ctl
do
  if [[ -e "${corectl}/enable" ]]
  then
      write "${corectl}/enable" "0"

   elif [[ -e "${corectl}/disable" ]]
   then
       write "${corectl}/disable" "1"
    fi
done

if [[ -e "/sys/power/cpuhotplug/enable" ]]
then
    write "/sys/power/cpuhotplug/enable" "0"

elif [[ -e "/sys/power/cpuhotplug/enabled" ]]
then
    write "/sys/power/cpuhotplug/enabled" "0"
fi

if [[ -e "/sys/kernel/intelli_plug" ]]; then
    write "/sys/kernel/intelli_plug/intelli_plug_active" "0"
fi

if [[ -e "/sys/module/blu_plug" ]]; then
    write "/sys/module/blu_plug/parameters/enabled" "0"
fi

if [[ -e "/sys/devices/virtual/misc/mako_hotplug_control" ]]; then
    write "/sys/devices/virtual/misc/mako_hotplug_control/enabled" "0"
fi

if [[ -e "/sys/module/autosmp" ]]; then
    write "/sys/module/autosmp/parameters/enabled" "0"
fi

if [[ -e "/sys/kernel/zen_decision" ]]; then
    write "/sys/kernel/zen_decision/enabled" "0"
fi

if [[ -e "/proc/hps" ]]; then
    write "/proc/hps/enabled" "0"
fi

kmsg "Disabled core control & CPU hotplug"
kmsg3 ""

# Caf CPU Boost
if [[ -d "/sys/module/cpu_boost" ]]
then
    write "/sys/module/cpu_boost/parameters/input_boost_ms" "250"
    write "/sys/module/cpu_boost/parameters/input_boost_enabled" "1"
    write "/sys/module/cpu_boost/parameters/sched_boost_on_input" "1"
    kmsg "Tweaked CAF CPU input boost"
    kmsg3 ""

# CPU input boost
elif [[ -d "/sys/module/cpu_input_boost" ]]
then
    write "/sys/module/cpu_input_boost/parameters/input_boost_duration" "250"
    kmsg "Tweaked CPU input boost"
    kmsg3 ""
fi

# I/O Scheduler Tweaks
for queue in /sys/block/*/queue/
do

    # Choose the first governor available
	avail_scheds="$(cat "$queue/scheduler")"
	for sched in tripndroid fiops bfq-sq bfq-mq bfq zen sio anxiety mq-deadline kyber cfq noop none
	do
		if [[ "$avail_scheds" == *"$sched"* ]]
		then
			write "$queue/scheduler" "$sched"
			break
		fi
	done
	
   write "${queue}add_random" 0
   write "${queue}iostats" 0
   write "${queue}rotational" 0
   write "${queue}read_ahead_kb" 512
   write "${queue}nomerges" 2
   write "${queue}rq_affinity" 2
   write "${queue}nr_requests" 256
done

kmsg "Tweaked I/O scheduler"
kmsg3 ""

# CPU Tweaks
for cpu in /sys/devices/system/cpu/cpu*/cpufreq
do
	# Fetch the available governors from the CPU
	avail_govs="$(cat "$cpu/scaling_available_governors")"

	# Attempt to set the governor in this order
	for governor in schedutil interactive
	do
		# Once a matching governor is found, set it and break for this CPU
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$cpu/scaling_governor" "$governor"
			break
		fi
	done
done

# Apply governor specific tunables for schedutil
find /sys/devices/system/cpu/ -name schedutil -type d | while IFS= read -r governor
do
   write "$governor/up_rate_limit_us" "0"
   write "$governor/down_rate_limit_us" "0"
   write "$governor/pl" "1"
   write "$governor/iowait_boost_enable" "1"
   write "$governor/rate_limit_us" "0"
   write "$governor/hispeed_load" "80"
   write "$governor/hispeed_freq" "$cpu_max_freq"
done

# Apply governor specific tunables for interactive
find /sys/devices/system/cpu/ -name interactive -type d | while IFS= read -r governor
do
   write "$governor/timer_rate" "0"
   write "$governor/boost" "1"
   write "$governor/timer_slack" "0"
   write "$governor/input_boost" "1"
   write "$governor/use_migration_notif" "0"
   write "$governor/ignore_hispeed_on_notif" "1"
   write "$governor/use_sched_load" "1"
   write "$governor/boostpulse" "0"
   write "$governor/fastlane" "1"
   write "$governor/fast_ramp_down" "0"
   write "$governor/sampling_rate" "0"
   write "$governor/sampling_rate_min" "0"
   write "$governor/min_sample_time" "0"
   write "$governor/go_hispeed_load" "80"
   write "$governor/hispeed_freq" "$cpu_max_freq"
done

if [[ -e "/proc/cpufreq/cpufreq_power_mode" ]];
    write "/proc/cpufreq/cpufreq_power_mode" "3"
fi

if [[ -e "/proc/cpufreq/cpufreq_cci_mode" ]]; then
    write "/proc/cpufreq/cpufreq_cci_mode" "1"
fi

if [[ -e "/proc/cpufreq/cpufreq_stress_test" ]]; then
    write "/proc/cpufreq/cpufreq_stress_test" "1"
fi

[[ "$ppm" == "true" ]] && write "/proc/ppm/enabled" "0"

for i in 0 1 2 3 4 5 6 7 8 9
do
  write "/sys/devices/system/cpu/cpu$i/online" "1"
done

kmsg "Tweaked CPU parameters"
kmsg3 ""

if [[ -e "/sys/kernel/hmp" ]]; then
    write "/sys/kernel/hmp/boost" "1"
    write "/sys/kernel/hmp/down_compensation_enabled" "1"
    write "/sys/kernel/hmp/family_boost" "1"
    write "/sys/kernel/hmp/semiboost" "1"
    write "/sys/kernel/hmp/up_threshold" "400"
    write "/sys/kernel/hmp/down_threshold" "125"
    kmsg "Tweaked HMP parameters"
    kmsg3 ""
fi

# GPU Tweaks

	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/devfreq/available_governors")"

	# Attempt to set the governor in this order
	for governor in msm-adreno-tz simple_ondemand ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/devfreq/governor" "$governor"
			break
		fi
	done
	
	# Fetch the available governors from the GPU
	avail_govs="$(cat "$gpui/gpu_available_governor")"

	# Attempt to set the governor in this order
	for governor in Booster Interactive Dynamic Static
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpui/gpu_governor" "$governor"
			break
		fi
	done

    # Fetch the available governors from the GPU
	avail_govs="$(cat "$gpu/available_governors")"

	# Attempt to set the governor in this order
	for governor in Interactive Dynamic Static ondemand
	do
		# Once a matching governor is found, set it and break
		if [[ "$avail_govs" == *"$governor"* ]]
		then
			write "$gpu/governor" "$governor"
			break
		fi
	done

if [[ $qcom == "true" ]]; then
    write "$gpu/throttling" "0"
    write "$gpu/thermal_pwrlevel" "$gpu_calc_thrtl"
    write "$gpu/devfreq/adrenoboost" "3"
    write "$gpu/force_no_nap" "1"
    write "$gpu/bus_split" "0"
    write "$gpu/devfreq/max_freq" "$gpu_max_freq"
    write "$gpu/devfreq/min_freq" "$gpu_max"
    write "$gpu/default_pwrlevel" "$gpu_max_pl"
    write "$gpu/force_bus_on" "1"
    write "$gpu/force_clk_on" "1"
    write "$gpu/force_rail_on" "1"
    write "$gpu/idle_timer" "1000000"
    write "$gpu/pwrnap" "0"
else
    [[ $one_ui == "false" ]] && write "$gpu/dvfs" "0"
     write "$gpui/gpu_min_clock" "$gpu_max2"
     write "$gpu/highspeed_clock" "$gpu_max_freq"
     write "$gpu/highspeed_load" "76"
     write "$gpu/highspeed_delay" "0"
     write "$gpu/power_policy" "always_on"
     write "$gpu/cl_boost_disable" "0"
     write "$gpui/boost" "1"
     write "$gpug/mali_touch_boost_level" "1"
     write "/proc/gpufreq/gpufreq_input_boost" "1"
     write "$gpu/max_freq" "$gpu_max_freq"
     write "$gpu/min_freq" "$gpu_max2"
     write "$gpu/tmu" "0"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync "0"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_upthreshold "35"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/vsync_downdifferential "15"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_upthreshold "25"
     write "$gpu"/devfreq/gpufreq/mali_ondemand/no_vsync_downdifferential "10"
fi

if [[ -d "/sys/modules/ged/" ]]
then
    write "/sys/module/ged/parameters/ged_boost_enable" "1"
    write "/sys/module/ged/parameters/boost_gpu_enable" "1"
    write "/sys/module/ged/parameters/boost_extra" "1"
    write "/sys/module/ged/parameters/enable_cpu_boost" "1"
    write "/sys/module/ged/parameters/enable_gpu_boost" "1"
    write "/sys/module/ged/parameters/enable_game_self_frc_detect" "1"
    write "/sys/module/ged/parameters/ged_force_mdp_enable" "0"
    write "/sys/module/ged/parameters/ged_log_perf_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_log_trace_enable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_debug" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_disable" "0"
    write "/sys/module/ged/parameters/ged_monitor_3D_fence_systrace" "0"
    write "/sys/module/ged/parameters/ged_smart_boost" "0"
    write "/sys/module/ged/parameters/gpu_debug_enable" "0"
    write "/sys/module/ged/parameters/gpu_dvfs_enable" "0"
    write "/sys/module/ged/parameters/gx_3D_benchmark_on" "1"
    write "/sys/module/ged/parameters/gx_dfps" "1"
    write "/sys/module/ged/parameters/gx_force_cpu_boost" "1"
    write "/sys/module/ged/parameters/gx_frc_mode" "1"
    write "/sys/module/ged/parameters/gx_game_mode" "1"
    write "/sys/module/ged/parameters/is_GED_KPI_enabled" "1"
fi

if [[ -d "/proc/gpufreq/" ]]
then
    write "/proc/gpufreq/gpufreq_opp_freq" "$gpu_max3"
    write "/proc/gpufreq/gpufreq_limited_thermal_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_oc_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volume_ignore" "1"
    write "/proc/gpufreq/gpufreq_limited_low_batt_volt_ignore" "1"
fi

# Tweak some mali parameters
if [[ -d "/proc/mali/" ]] 
then
     [[ $one_ui == "false" ]] && write "/proc/mali/dvfs_enable" "0"
     write "/proc/mali/always_on" "1"
fi

if [[ -e "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" ]] 
then
    write "/sys/module/pvrsrvkm/parameters/gpu_dvfs_enable" "0"
fi

if [[ -e "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" ]]
then
    write "/sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate" "Y"
fi

kmsg "Tweaked GPU parameters"
kmsg3 ""

if [[ -e "/sys/module/cryptomgr/parameters/notests" ]]
then
    write "/sys/module/cryptomgr/parameters/notests" "Y"
    kmsg "Disabled forced cryptography tests"
    kmsg3 ""
fi

# Disable adreno idler
if [[ -d "/sys/module/adreno_idler" ]]
then
    write "/sys/module/adreno_idler/parameters/adreno_idler_active" "N"
    kmsg "Disabled adreno idler"
    kmsg3 ""
fi

# Schedtune Tweaks
if [[ -d "$stune" ]]
then
    write "${stune}background/schedtune.boost" "0"
    write "${stune}background/schedtune.prefer_idle" "0"
    write "${stune}background/schedtune.sched_boost" "0"
    write "${stune}background/schedtune.prefer_perf" "0"

    write "${stune}foreground/schedtune.boost" "50"
    write "${stune}foreground/schedtune.prefer_idle" "0"
    write "${stune}foreground/schedtune.sched_boost" "15"
    write "${stune}foreground/schedtune.sched_boost_no_override" "1"
    write "${stune}foreground/schedtune.prefer_perf" "0"

    write "${stune}rt/schedtune.boost" "0"
    write "${stune}rt/schedtune.prefer_idle" "0"
    write "${stune}rt/schedtune.sched_boost" "0"
    write "${stune}rt/schedtune.prefer_perf" "0"

    write "${stune}top-app/schedtune.boost" "50"
    write "${stune}top-app/schedtune.prefer_idle" "1"
    write "${stune}top-app/schedtune.sched_boost" "15"
    write "${stune}top-app/schedtune.sched_boost_no_override" "1"
    write "${stune}top-app/schedtune.prefer_perf" "1"

    write "${stune}schedtune.boost" "0"
    write "${stune}schedtune.prefer_idle" "0"
    kmsg "Tweaked cpuset schedtune"
    kmsg3 ""
fi

# Uclamp Tweaks
if [[ -e "${cpuset}top-app/uclamp.max" ]]
then
    sysctl -w kernel.sched_util_clamp_min_rt_default=96
    sysctl -w kernel.sched_util_clamp_min=192
 
    write "${cpuset}top-app/uclamp.max" "max"
    write "${cpuset}top-app/uclamp.min" "max"
    write "${cpuset}top-app/uclamp.boosted" "1"
    write "${cpuset}top-app/uclamp.latency_sensitive" "1"

    write "${cpuset}foreground/uclamp.max" "max"
    write "${cpuset}foreground/uclamp.min" "max"
    write "${cpuset}foreground/uclamp.boosted" "1"
    write "${cpuset}foreground/uclamp.latency_sensitive" "1"

    write "${cpuset}background/uclamp.max" "50"
    write "${cpuset}background/uclamp.min" "0"
    write "${cpuset}background/uclamp.boosted" "0"
    write "${cpuset}background/uclamp.latency_sensitive" "0"

    write "${cpuset}system-background/uclamp.max" "40"
    write "${cpuset}system-background/uclamp.min" "0"
    write "${cpuset}system-background/uclamp.boosted" "0"
    write "${cpuset}system-background/uclamp.latency_sensitive" "0"
    kmsg "Tweaked cpuset uclamp"
    kmsg3 ""
fi

# FS Tweaks
if [[ -d "/proc/sys/fs" ]]
then
    write "/proc/sys/fs/dir-notify-enable" "0"
    write "/proc/sys/fs/lease-break-time" "10"
    write "/proc/sys/fs/leases-enable" "1"
    write "/proc/sys/fs/inotify/max_queued_events" "131072"
    write "/proc/sys/fs/inotify/max_user_watches" "131072"
    write "/proc/sys/fs/inotify/max_user_instances" "1024"
    kmsg "Tweaked FS"
    kmsg3 ""
fi

# Enable dynamic_fsync
if [[ -e "/sys/kernel/dyn_fsync/Dyn_fsync_active" ]]
then
    write "/sys/kernel/dyn_fsync/Dyn_fsync_active" "1"
    kmsg "Enabled dynamic fsync"
    kmsg3 ""
fi

# Scheduler features
if [[ -e "/sys/kernel/debug/sched_features" ]]
then
    write "/sys/kernel/debug/sched_features" "NEXT_BUDDY"
    write "/sys/kernel/debug/sched_features" "TTWU_QUEUE"
    write "/sys/kernel/debug/sched_features" "UTIL_EST"
    [[ $cpu_sched == "EAS" ]] && write "/sys/kernel/debug/sched_features" "EAS_PREFER_IDLE"
    kmsg "Tweaked scheduler features"
    kmsg3 ""
fi

if [[ -e "/sys/module/mmc_core/parameters/use_spi_crc" ]]; then
    write "/sys/module/mmc_core/parameters/use_spi_crc" "N"
    kmsg "Disabled MMC CRC"
    kmsg3 ""

elif [[ -e "/sys/module/mmc_core/parameters/removable" ]]; then
      write "/sys/module/mmc_core/parameters/removable" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""
  
elif [[ -e "/sys/module/mmc_core/parameters/crc" ]]; then
      write "/sys/module/mmc_core/parameters/crc" "N"
      kmsg "Disabled MMC CRC"
      kmsg3 ""
fi

# Tweak some kernel settings to improve overall performance.
if [[ -e "${kernel}sched_child_runs_first" ]]; then
    write "${kernel}sched_child_runs_first" "0"
fi
if [[ -e "${kernel}perf_cpu_time_max_percent" ]]; then
    write "${kernel}perf_cpu_time_max_percent" "25"
fi
if [[ -e "${kernel}sched_autogroup_enabled" ]]; then
    write "${kernel}sched_autogroup_enabled" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkscale_enable" ]]; then
    write "/sys/devices/soc/$dv/clkscale_enable" "0"
fi
if [[ -e "/sys/devices/soc/$dv/clkgate_enable" ]]; then
    write "/sys/devices/soc/$dv/clkgate_enable" "0"
fi
write "${kernel}sched_tunable_scaling" "0"
if [[ -e "${kernel}sched_latency_ns" ]]; then
    write "${kernel}sched_latency_ns" "$SCHED_PERIOD_THROUGHPUT"
fi
if [[ -e "${kernel}sched_min_granularity_ns" ]]; then
    write "${kernel}sched_min_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / SCHED_TASKS_THROUGHPUT))"
fi
if [[ -e "${kernel}sched_wakeup_granularity_ns" ]]; then
    write "${kernel}sched_wakeup_granularity_ns" "$((SCHED_PERIOD_THROUGHPUT / 2))"
fi
if [[ -e "${kernel}sched_migration_cost_ns" ]]; then
    write "${kernel}sched_migration_cost_ns" "5000000"
fi
if [[ -e "${kernel}sched_min_task_util_for_colocation" ]]; then
    write "${kernel}sched_min_task_util_for_colocation" "0"
fi
if [[ -e "${kernel}sched_min_task_util_for_boost" ]]; then
    write "${kernel}sched_min_task_util_for_boost" "0"
fi
write "${kernel}sched_nr_migrate" "128"
write "${kernel}sched_schedstats" "0"
if [[ -e "${kernel}sched_cstate_aware" ]]; then
    write "${kernel}sched_cstate_aware" "1"
fi
write "${kernel}printk_devkmsg" "off"
if [[ -e "${kernel}timer_migration" ]]; then
    write "${kernel}timer_migration" "0"
fi
if [[ -e "${kernel}sched_boost" ]]; then
    write "${kernel}sched_boost" "1"
fi
if [[ -e "/sys/devices/system/cpu/eas/enable" ]] && [[ "$mtk" == "true" ]]; then
    write "/sys/devices/system/cpu/eas/enable" "2"
else
    write "/sys/devices/system/cpu/eas/enable" "1"
fi
if [[ -e "/proc/ufs_perf" ]]; then
    write "/proc/ufs_perf" "2"
fi
if [[ -e "/proc/cpuidle/enable" ]]; then
    write "/proc/cpuidle/enable" "0"
fi
if [[ -e "/sys/kernel/debug/eara_thermal/enable" ]]; then
    write "/sys/kernel/debug/eara_thermal/enable" "0"
fi

# Enable UTW (UFS Turbo Write)
for ufs in /sys/devices/platform/soc/*.ufshc/ufstw_lu*; do
   if [[ -d "$ufs" ]]; then
       write "${ufs}tw_enable" "1"
       kmsg "Enabled UFS Turbo Write"
       kmsg3 ""
     fi
  break
done

if [[ -e "/sys/power/little_thermal_temp" ]]; then
    write "/sys/power/little_thermal_temp" "90"
fi

kmsg "Tweaked various kernel parameters"
kmsg3 ""

# Enable fingerprint boost
if [[ -e "/sys/kernel/fp_boost/enabled" ]]
then
    write "/sys/kernel/fp_boost/enabled" "1"
    kmsg "Enabled fingerprint boost"
    kmsg3 ""
fi

# Set min and max clocks
for cpus in /sys/devices/system/cpu/cpufreq/policy*/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_max_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

for cpus in /sys/devices/system/cpu/cpu*/cpufreq/
do
  if [[ -e "${cpus}scaling_min_freq" ]]
  then
      write "${cpus}scaling_min_freq" "$cpu_max_freq"
      write "${cpus}scaling_max_freq" "$cpu_max_freq"
   fi
done

kmsg "Tweaked CPU clocks"
kmsg3 ""

if [[ -e "/sys/devices/system/cpu/cpuidle/use_deepest_state" ]] 
then
    write "/sys/devices/system/cpu/cpuidle/use_deepest_state" "0"
    kmsg "Not allowed CPUs to use it's deepest idle state"
    kmsg3 ""
fi

# Enable krait voltage boost
if [[ -e "/sys/module/acpuclock_krait/parameters/boost" ]] 
then
    write "/sys/module/acpuclock_krait/parameters/boost" "Y"
    kmsg "Enabled krait voltage boost"
    kmsg3 ""
fi

fr=$(((total_ram * 3 / 2 / 100) * 1024 / 4))
bg=$(((total_ram * 2 / 100) * 1024 / 4))
et=$(((total_ram * 4 / 100) * 1024 / 4))
mr=$(((total_ram * 7 / 100) * 1024 / 4))
cd=$(((total_ram * 11 / 100) * 1024 / 4))
ab=$(((total_ram * 13 / 100) * 1024 / 4))

efr=$((mfr * 16 / 5))

if [[ "$efr" -le "18432" ]]; then
    efr=18432
fi

mfr=$((total_ram * 6 / 5))

if [[ "$mfr" -le "3072" ]]; then
    mfr=3072
fi

# always sync before dropping caches
sync

# VM settings to improve overall user experience and performance.
write "${vm}drop_caches" "3"
write "${vm}dirty_background_ratio" "15"
write "${vm}dirty_ratio" "30"
write "${vm}dirty_expire_centisecs" "3000"
write "${vm}dirty_writeback_centisecs" "3000"
write "${vm}page-cluster" "0"
write "${vm}stat_interval" "60"
write "${vm}extfrag_threshold" "750"
# Use SSWAP defaults if device haven't more than 3 GB RAM on exynos SOC's
if [[ "$exynos" == "true" ]] && [[ $total_ram -lt "3000" ]]; then
    write "${vm}swappiness" "150"
else
    write "${vm}swappiness" "100"
fi
write "${vm}laptop_mode" "0"
write "${vm}vfs_cache_pressure" "200"
if [[ -e "/sys/module/process_reclaim/parameters/enable_process_reclaim" ]] | [[ $total_ram -lt "5000" ]]; then
    write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
fi
write "${vm}reap_mem_on_sigkill" "1"

# Tune lmk_minfree
if [[ -e "${lmk}/parameters/minfree" ]]; then
    write "${lmk}/parameters/minfree" "$fr,$bg,$et,$mr,$cd,$ab"
fi

# Enable oom_reaper
if [[ -e "${lmk}parameters/oom_reaper" ]]; then
    write "${lmk}parameters/oom_reaper" "1"
fi
	
# Enable lmk_fast_run
if [[ -e "${lmk}parameters/lmk_fast_run" ]]; then
    write "${lmk}parameters/lmk_fast_run" "1"
fi

# Enable adaptive_lmk
if [[ -e "${lmk}parameters/enable_adaptive_lmk" ]]; then
    write "${lmk}parameters/enable_adaptive_lmk" "1"
fi

# Tune vm_min_free_kbytes
if [[ -e "${vm}min_free_kbytes" ]]; then
    write "${vm}min_free_kbytes" "$mfr"
fi
  
# Tune vm_extra_free_kbytes
if [[ -e "${vm}extra_free_kbytes" ]]; then
    write "${vm}extra_free_kbytes" "$efr"
fi

kmsg "Tweaked various VM and LMK parameters for a improved user-experience"
kmsg3 ""

# MSM thermal tweaks
if [[ -d "/sys/module/msm_thermal" ]]
then
    write "/sys/module/msm_thermal/vdd_restriction/enabled" "0"
    write "/sys/module/msm_thermal/core_control/enabled" "0"
    write "/sys/module/msm_thermal/parameters/enabled" "N"
    kmsg "Tweaked msm_thermal"
    kmsg3 ""
fi

# Disable power efficient workqueue
if [[ -e "/sys/module/workqueue/parameters/power_efficient" ]]
then 
    write "/sys/module/workqueue/parameters/power_efficient" "N" 
    kmsg "Disabled CPU power efficient workqueue"
    kmsg3 ""
fi

if [[ -e "/sys/devices/system/cpu/sched_mc_power_savings" ]]
then
    write "/sys/devices/system/cpu/sched_mc_power_savings" "0"
    kmsg "Disabled CPU scheduler multi-core power-saving"
    kmsg3 ""
fi

# Fix DT2W
if [[ -e "/sys/touchpanel/double_tap" ]] && [[ -e "/proc/tp_gesture" ]]
then
    write "/sys/touchpanel/double_tap" "1"
    write "/proc/tp_gesture" "1"
    kmsg "Fix DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/class/sec/tsp/dt2w_enable" ]]
then
    write "/sys/class/sec/tsp/dt2w_enable" "1"
    kmsg "Fix DT2W if broken"
    kmsg3 ""

elif [[ -e "/proc/tp_gesture" ]]
then
    write "/proc/tp_gesture" "1"
    kmsg "Fix DT2W if broken"
    kmsg3 ""

elif [[ -e "/sys/touchpanel/double_tap" ]]
then
    write "/sys/touchpanel/double_tap" "1"
    kmsg "Fix DT2W if broken"
    kmsg3 ""
fi

# Enable touch boost on gaming and performance profile.
if [[ -e "/sys/module/msm_performance/parameters/touchboost" ]]
then
    write "/sys/module/msm_performance/parameters/touchboost" "1"
    kmsg "Enabled msm_performance touch boost"
    kmsg3 ""

elif [[ -e "/sys/power/pnpmgr/touch_boost" ]]
then
    write "/sys/power/pnpmgr/touch_boost" "1"
    write "/sys/power/pnpmgr/long_duration_touch_boost" "1"
    kmsg "Enabled pnpmgr touch boost"
    kmsg3 ""
fi

# Fetch the available TCP congestion control 
avail_con="$(cat "${tcp}tcp_available_congestion_control")"
	
    # Attempt to set the TCP congestion control in this order
    for tcpcc in bbr2 bbr westwood cubic  
	do
	    # Once a matching TCP congestion control is found, set it and break
		if [[ "$avail_con" == *"$tcpcc"* ]]
		then
			write ${tcp}tcp_congestion_control $tcpcc
			break
		fi
	done
	
# TCP Tweaks
write "${tcp}ip_no_pmtu_disc" "0"
write "${tcp}tcp_ecn" "1"
write "${tcp}tcp_timestamps" "0"
write "${tcp}route.flush" "1"
write "${tcp}tcp_rfc1337" "1"
write "${tcp}tcp_tw_reuse" "1"
write "${tcp}tcp_sack" "1"
write "${tcp}tcp_fack" "1"
write "${tcp}tcp_fastopen" "3"
write "${tcp}tcp_tw_recycle" "1"
write "${tcp}tcp_no_metrics_save" "1"
write "${tcp}tcp_syncookies" "0"
write "${tcp}tcp_window_scaling" "1"
write "${tcp}tcp_keepalive_probes" "10"
write "${tcp}tcp_keepalive_intvl" "30"
write "${tcp}tcp_fin_timeout" "30"
write "${tcp}tcp_low_latency" "1"
write "/proc/sys/net/core/netdev_tstamp_prequeue" "0"

kmsg "Applied TCP tweaks"
kmsg3 ""

# Disable kernel battery saver
if [[ -d "/sys/module/battery_saver" ]]
then
    write "/sys/module/battery_saver/parameters/enabled" "N"
    kmsg "Disabled kernel battery saver"
    kmsg3 ""
fi

# Enable high performance audio
for hpm in /sys/module/snd_soc_wcd*
do
  if [[ -e "$hpm" ]]
  then
      write "${hpm}/parameters/high_perf_mode" "1"
      kmsg "Enabled high performance audio"
      kmsg3 ""
      break
   fi
done

# Disable LPM in extreme / gaming profile
for lpm in /sys/module/lpm_levels/system/*/*/*/
do
  if [[ -d "/sys/module/lpm_levels" ]]
  then
      write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
      write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
      write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
      write "${lpm}idle_enabled" "N"
      write "${lpm}suspend_enabled" "N"
   fi
done

kmsg "Disabled LPM"
kmsg3 ""

if [[ -e "/sys/module/pm2/parameters/idle_sleep_mode" ]] 
then
    write "/sys/module/pm2/parameters/idle_sleep_mode" "N"
    kmsg "Disabled pm2 idle sleep mode"
    kmsg3 ""
fi

if [[ -e "/sys/class/lcd/panel/power_reduce" ]] 
then
    write "/sys/class/lcd/panel/power_reduce" "0"
    kmsg "Disabled LCD power reduce"
    kmsg3 ""
fi

# Enable Fast Charging Rate
if [[ -e "/sys/kernel/fast_charge/force_fast_charge" ]]
then
    write "/sys/kernel/fast_charge/force_fast_charge" "1"
    kmsg "Enabled USB 3.0 fast charging"
    kmsg3 ""
fi

if [[ -e "/sys/class/sec/switch/afc_disable" ]];
then
    write "/sys/class/sec/switch/afc_disable" "0"
    kmsg "Enabled fast charging on Samsung devices"
    kmsg3 ""
fi
  
kmsg "Gaming profile applied. Enjoy!"
kmsg3 ""

kmsg "End of execution: $(date)"
kmsg3 ""
exit=$(date +%s)

exectime=$((exit - init))
kmsg "Elapsed time: $exectime seconds."
}