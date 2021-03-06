#!/bin/ash

CFG=/etc/board.json

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

json_select_array() {
	local _json_no_warning=1

	json_select "$1"
	[ $? = 0 ] && return

	json_add_array "$1"
	json_close_array

	json_select "$1"
}

json_select_object() {
	local _json_no_warning=1

	json_select "$1"
	[ $? = 0 ] && return

	json_add_object "$1"
	json_close_object

	json_select "$1"
}

_ucidef_set_interface() {
	local name="$1"
	local iface="$2"

	json_select_object "$name"
	json_add_string ifname "$iface"
	json_select ..
}

ucidef_set_board_id() {
	json_select_object model
	json_add_string id "$1"
	json_select ..
}

ucidef_set_model_name() {
	json_select_object model
	json_add_string name "$1"
	json_select ..
}

ucidef_set_interface_loopback()
{
	# stub
	local a="$1"
}

ucidef_set_interface_lan() {
	local lan_if="$1"

	json_select_object network
	_ucidef_set_interface lan "$lan_if"
	json_select ..
}

ucidef_set_interface_wan() {
        local wan_if="$1"

        json_select_object network
        _ucidef_set_interface wan "$wan_if"
        json_select ..
}

ucidef_set_interfaces_lan_wan() {
	local lan_if="$1"
	local wan_if="$2"

	json_select_object network
	_ucidef_set_interface lan "$lan_if"
	_ucidef_set_interface wan "$wan_if"
	json_select ..
}

_ucidef_add_switch_port() {
	# inherited: $num $device $need_tag $role $index $prev_role
	# inherited: $n_cpu $n_ports $n_vlan $cpu0 $cpu1 $cpu2 $cpu3 $cpu4 $cpu5

	n_ports=$((n_ports + 1))

	json_select_array ports
		json_add_object
			json_add_int num "$num"
			[ -n "$device"   ] && json_add_string  device   "$device"
			[ -n "$need_tag" ] && json_add_boolean need_tag "$need_tag"
			[ -n "$role"     ] && json_add_string  role     "$role"
			[ -n "$index"    ] && json_add_int     index    "$index"
		json_close_object
	json_select ..

	# record pointer to cpu entry for lookup in _ucidef_finish_switch_roles()
	[ -n "$device" ] && {
		export "cpu$n_cpu=$n_ports"
		n_cpu=$((n_cpu + 1))
	}

	# create/append object to role list
	[ -n "$role" ] && {
		json_select_array roles

		if [ "$role" != "$prev_role" ]; then
			json_add_object
				json_add_string role "$role"
				json_add_string ports "$num"
			json_close_object

			prev_role="$role"
			n_vlan=$((n_vlan + 1))
		else
			json_select_object "$n_vlan"
				json_get_var port ports
				json_add_string ports "$port $num"
			json_select ..
		fi

		json_select ..
	}
}

_ucidef_finish_switch_roles() {
	# inherited: $name $n_cpu $n_vlan $cpu0 $cpu1 $cpu2 $cpu3 $cpu4 $cpu5
	local index role roles num device need_tag port ports

	json_select switch
		json_select "$name"
			json_get_keys roles roles
		json_select ..
	json_select ..

	for index in $roles; do
		eval "port=\$cpu$(((index - 1) % n_cpu))"

		json_select switch
			json_select "$name"
				json_select ports
					json_select "$port"
						json_get_vars num device need_tag
					json_select ..
				json_select ..

				if [ $n_vlan -gt $n_cpu -o ${need_tag:-0} -eq 1 ]; then
					num="${num}t"
					device="${device}.${index}"
				fi

				json_select roles
					json_select "$index"
						json_get_vars role ports
						json_add_string ports "$ports $num"
						json_add_string device "$device"
					json_select ..
				json_select ..
			json_select ..
		json_select ..

		json_select_object network
			json_select_object "$role"
				# attach previous interfaces (for multi-switch devices)
				local prev_device; json_get_var prev_device ifname
				if ! list_contains prev_device "$device"; then
					device="${prev_device:+$prev_device }$device"
				fi
				json_add_string ifname "$device"
			json_select ..
		json_select ..
	done
}

ucidef_add_switch() {
	local name="$1"; shift
	local port num role device index need_tag prev_role
	local cpu0 cpu1 cpu2 cpu3 cpu4 cpu5
	local n_cpu=0 n_vlan=0 n_ports=0

	json_select_object switch
		json_select_object "$name"
			json_add_boolean enable 1
			json_add_boolean reset 1

			for port in "$@"; do
				case "$port" in
					[0-9]*@*)
						num="${port%%@*}"
						device="${port##*@}"
						need_tag=0
						[ "${num%t}" != "$num" ] && {
							num="${num%t}"
							need_tag=1
						}
					;;
					[0-9]*:*:[0-9]*)
						num="${port%%:*}"
						index="${port##*:}"
						role="${port#[0-9]*:}"; role="${role%:*}"
					;;
					[0-9]*:*)
						num="${port%%:*}"
						role="${port##*:}"
					;;
				esac

				if [ -n "$num" ] && [ -n "$device$role" ]; then
					_ucidef_add_switch_port
				fi

				unset num device role index need_tag
			done
		json_select ..
	json_select ..

	_ucidef_finish_switch_roles
}

ucidef_add_switch_attr() {
	local name="$1"
	local key="$2"
	local val="$3"

	json_select_object switch
		json_select_object "$name"

		case "$val" in
			true|false) [ "$val" != "true" ]; json_add_boolean "$key" $? ;;
			[0-9]) json_add_int "$key" "$val" ;;
			*) json_add_string "$key" "$val" ;;
		esac

		json_select ..
	json_select ..
}

ucidef_add_switch_port_attr() {
	local name="$1"
	local port="$2"
	local key="$3"
	local val="$4"
	local ports i num

	json_select_object switch
	json_select_object "$name"

	json_get_keys ports ports
	json_select_array ports

	for i in $ports; do
		json_select "$i"
		json_get_var num num

		if [ -n "$num" ] && [ $num -eq $port ]; then
			json_select_object attr

			case "$val" in
				true|false) [ "$val" != "true" ]; json_add_boolean "$key" $? ;;
				[0-9]) json_add_int "$key" "$val" ;;
				*) json_add_string "$key" "$val" ;;
			esac

			json_select ..
		fi

		json_select ..
	done

	json_select ..
	json_select ..
	json_select ..
}

ucidef_set_interface_macaddr() {
	local network="$1"
	local macaddr="$2"

	json_select_object network

	json_select "$network"
	[ $? -eq 0 ] || {
		json_select ..
		return
	}

	json_add_string macaddr "$macaddr"
	json_select ..

	json_select ..
}

ucidef_set_led_netdev() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local dev="$4"

	json_select_object led

	json_select_object "$1"
	json_add_string name "$name"
	json_add_string type netdev
	json_add_string sysfs "$sysfs"
	json_add_string device "$dev"
	json_select ..

	json_select ..
}

ucidef_set_led_usbdev() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local dev="$4"

	json_select_object led

	json_select_object "$1"
	json_add_string name "$name"
	json_add_string type usb
	json_add_string sysfs "$sysfs"
	json_add_string device "$dev"
	json_select ..

	json_select ..
}

ucidef_set_led_wlan() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local trigger="$4"

	json_select_object led

	json_select_object "$1"
	json_add_string name "$name"
	json_add_string type trigger
	json_add_string sysfs "$sysfs"
	json_add_string trigger "$trigger"
	json_select ..

	json_select ..
}

ucidef_set_led_switch() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local trigger="$4"
	local port_mask="$5"

	json_select_object led

	json_select_object "$1"
	json_add_string name "$name"
	json_add_string type switch
	json_add_string sysfs "$sysfs"
	json_add_string trigger "$trigger"
	json_add_string port_mask "$port_mask"
	json_select ..

	json_select ..
}

ucidef_set_led_default() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local default="$4"

	json_select_object led

	json_select_object "$1"
	json_add_string name "$name"
	json_add_string sysfs "$sysfs"
	json_add_string default "$default"
	json_select ..

	json_select ..
}

ucidef_set_led_gpio() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local gpio="$4"
	local inverted="$5"

	json_select_object led

	json_select_object "$1"
	json_add_string type gpio
	json_add_string name "$name"
	json_add_string sysfs "$sysfs"
	json_add_string trigger "$trigger"
	json_add_int gpio "$gpio"
	json_add_boolean inverted "$inverted"
	json_select ..

	json_select ..
}

ucidef_set_led_rssi() {
	local cfg="led_$1"
	local name="$2"
	local sysfs="$3"
	local iface="$4"
	local minq="$5"
	local maxq="$6"
	local offset="$7"
	local factor="$8"

	json_select_object led

	json_select_object "$1"
	json_add_string type rssi
	json_add_string name "$name"
	json_add_string iface "$iface"
	json_add_string sysfs "$sysfs"
	json_add_string minq "$minq"
	json_add_string maxq "$maxq"
	json_add_string offset "$offset"
	json_add_string factor "$factor"
	json_select ..

	json_select ..
}

ucidef_set_rssimon() {
	local dev="$1"
	local refresh="$2"
	local threshold="$3"

	json_select_object rssimon

	json_select_object "$dev"
	[ -n "$refresh" ] && json_add_int refresh "$refresh"
	[ -n "$threshold" ] && json_add_int threshold "$threshold"
	json_select ..

	json_select ..

}

board_config_update() {
	json_init
	[ -f ${CFG} ] && json_load "$(cat ${CFG})"
}

board_config_flush() {
	json_dump -i > /tmp/.board.json
	mv /tmp/.board.json ${CFG}
}
