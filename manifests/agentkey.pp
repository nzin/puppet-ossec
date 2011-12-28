#
# utility function to fill up /var/ossec/etc/client.keys
#
define ossec::agentKey($agent_id,$agent_name, $agent_ip_address, $agent_seed = "xaeS7ahf") {
	if ! $agent_id { fail("ossec::agentKey: $agentId is missing")}
	
	$agentKey1 = ossec_md5("$agent_id $agent_seed")
	$agentKey2 = ossec_md5("$agent_name $agent_ip_address $agent_seed")
#	$agent_id_str = sprintf("%03d",$agent_id)
	
	include concat::setup
	concat::fragment { "var_ossec_etc_client.keys_${agent_ip_address}_part":
		target  => "/var/ossec/etc/client.keys",
		order   => $agentId,
		content => "$agent_id $agent_name $agent_ip_address ${agentKey1}${agentKey2}\n",
		#content => "$agent_id_str $agent_name $agent_ip_address ${agentKey1}${agentKey2}\n",
	}

}
