#!/bin/sh
#script by Abi Darwish

CORE_COUNT=$(( $(grep "^processor" /proc/cpuinfo | tail -1 | awk '{print $3}') + 1 ))

if [[ ${CORE_COUNT} != 4 ]]; then
    echo "Your device is not compatible"
    exit 1
fi

echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor

if [[ -z $(which irqbalance) ]]; then
    opkg update
    opkg install irqbalance
    sed -i "s/enabled \'0\'/enabled \'1\'/" /etc/config/irqbalance
fi

sed -i "s/#option interval .*$/option interval '1'/" /etc/config/irqbalance
sed -i "s/option interval .*$/option interval '1'/" /etc/config/irqbalance
/etc/init.d/irqbalance restart

if [[ -z $(which htop) ]]; then
    opkg update
    opkg install htop
fi

if [[ -e /etc/hotplug.d/net/20-smp-tune && ! -e /etc/arca/20-smp-tune.bak ]]; then
    [[ ! -e /etc/arca ]] && mkdir -p /etc/arca
    mv /etc/hotplug.d/net/20-smp-tune /etc/arca/20-smp-tune.bak
fi

cat << 'EOF' > /etc/hotplug.d/net/99-smp-tune
#!/bin/sh
#script by Abi Darwish

INTERRUPT=$(ls /proc/irq/ | sed '/default/d')

for i in ${INTERRUPT}; do
    if [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "usb3") != 0 ]]; then
        echo e > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "nss_queue1") != 0 ]]; then
        echo 2 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "nss_queue2") != 0 ]]; then
        echo 4 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "nss_queue3") != 0 ]]; then
        echo 8 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "arch_mem_timer") != 0 ]]; then
        echo 2 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "host2rxdma-monitor-ring1") != 0 ]]; then
        echo 8 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "host2rxdma-monitor-ring2") != 0 ]]; then
        echo 4 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "host2rxdma-monitor-ring3") != 0 ]]; then
        echo 2 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "rxdma2host-monitor-destination-mac1") != 0 ]]; then
        echo 8 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "rxdma2host-monitor-destination-mac2") != 0 ]]; then
        echo 4 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "rxdma2host-monitor-destination-mac3") != 0 ]]; then
        echo 2 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "ppdu-end-interrupts-mac1") != 0 ]]; then
        echo 8 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "ppdu-end-interrupts-mac2") != 0 ]]; then
        echo 4 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "ppdu-end-interrupts-mac3") != 0 ]]; then
        echo 2 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "rxdma2host-monitor-status-ring-mac1") != 0 ]]; then
        echo 8 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "rxdma2host-monitor-status-ring-mac2") != 0 ]]; then
        echo 4 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "rxdma2host-monitor-status-ring-mac3") != 0 ]]; then
        echo 2 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "wbm2host-tx-completions-ring4") != 0 ]]; then
        echo 8 > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "bam_dma") != 0 ]]; then
        echo f > /proc/irq/$i/smp_affinity
    elif [[ $(sed 's/^[ \t]*//' /proc/interrupts | grep "^$i:" | awk '{print $9}' | grep -c "ce") != 0 ]]; then
        echo f > /proc/irq/$i/smp_affinity
    else
        echo f > /proc/irq/$i/smp_affinity 2>/dev/null
    fi
done

IFACE=$(ls /sys/class/net)

for i in ${IFACE}; do
        ethtool -K $i gro on 2>/dev/null
        if [[ -e /sys/class/net/$i/queues/rx-0/rps_cpus ]]; then
            if [[ $i = "wwan0" ]]; then
                        echo f > /sys/class/net/$i/queues/rx-0/rps_cpus
              elif [[ $i = "wwan0_1" ]]; then
                        echo f > /sys/class/net/$i/queues/rx-0/rps_cpus
              elif [[ $i = "eth0" ]]; then
                        echo f > /sys/class/net/$i/queues/rx-0/rps_cpus
              elif [[ $i = "eth4" ]]; then
                        echo f > /sys/class/net/$i/queues/rx-0/rps_cpus
              elif [[ $i = "br-lan" ]]; then
                        echo f > /sys/class/net/$i/queues/rx-0/rps_cpus
              else
                echo f > /sys/class/net/$i/queues/rx-0/rps_cpus
            fi
        fi
        if [[ -e /sys/class/net/$i/queues/rx-0/rps_flow_cnt ]]; then
                echo 0 > /sys/class/net/$i/queues/rx-0/rps_flow_cnt
        fi
done
EOF

cat << 'EOF' > /etc/sysctl.d/99-gaza.conf
#memory optimized
vm.min_free_kbytes=1
vm.vfs_cache_pressure=500
vm.overcommit_memory=0
vm.overcommit_ratio=10
vm.dirty_ratio=20
vm.dirty_expire_centisecs=1500
vm.drop_caches=3
#Network Tweak Control
# allow testing with buffers up to 64MB 
net.core.rmem_max=67108864 
net.core.wmem_max=67108864 
# increase Linux autotuning TCP buffer limit to 32MB
net.ipv4.tcp_rmem=4096 87380 33554432
net.ipv4.tcp_wmem=4096 65536 33554432
# recommended default congestion control is htcp 
#net.ipv4.tcp_congestion_control = bbr
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1
#Others
fs.file-max=1000000
fs.inotify.max_user_instances=8192
net.ipv4.tcp_tw_reuse=1
net.ipv4.ip_local_port_range=1024 65000
net.ipv4.tcp_max_syn_backlog=1024
net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=5
net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
net.ipv4.tcp_synack_retries=3
#BETA
net.ipv4.tcp_max_tw_buckets=6000
net.ipv4.route.gc_timeout=100
net.core.somaxconn=32768
net.ipv4.tcp_max_orphans=32768
net.core.netdev_max_backlog=2000
net.netfilter.nf_conntrack_max=65535
net.core.rmem_default=256960
net.core.wmem_default=256960
net.core.optmem_max=81920
net.ipv4.tcp_mem=131072  262144  524288
net.ipv4.tcp_keepalive_time=1800
EOF

sh /etc/hotplug.d/net/99-smp-tune
sh /etc/hotplug.d/net/99-smp-tune
sysctl -p -q /etc/sysctl.d/99-gaza.conf
sysctl -p -q /etc/sysctl.d/99-gaza.conf

sed -i '/bypass700.sh/d' /etc/rc.local
sed -i '/gro.sh/d' /etc/rc.local
rm -rf /root/gro.sh
rm -rf /root/bypass700.sh
rm -rf /root/output.txt
rm -rf /etc/hotplug.d/net/20-smp-tune

clear

for i in $(ls /proc/irq | sed '/default/d'); do echo -e "$i\t$(sed 's/^ \|^  //' /proc/interrupts | grep "^$i:" | awk '{print $9}')\t$(cat /proc/irq/$i/smp_affinity)"; done

for i in $(ls /sys/class/net/ | sed '/bonding_master/d'); do echo -e "$i\tgro: $(ethtool -k $i | grep generic-receive-offload | awk '{print $2}')"; done

for i in $(ls /sys/class/net/ | sed '/bonding_master/d'); do echo -e "$i\t$(cat /sys/class/net/$i/queues/rx-0/rps_cpus)"; done

for i in $(ls /sys/class/net/ | sed '/bonding_master/d'); do echo -e "$i\t$(cat /sys/class/net/$i/queues/rx-0/rps_flow_cnt)"; done
echo
echo -e "Successful..."
echo
exit 0
