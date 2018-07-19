hostname ${node.name}
password ${node.password}

% if node.bgpd.logfile:
log file ${node.bgpd.logfile}
% endif

% for section in node.bgpd.debug:
debug bgp section
% endfor

router bgp ${node.bgpd.asn}
    bgp router-id ${node.bgpd.routerid}
    bgp bestpath compare-routerid
    % if node.bgpd.hold_time:
    timers bgp ${node.bgpd.hold_time/3} ${node.bgpd.hold_time}
    % endif
% for n in node.bgpd.neighbors:
    no auto-summary
    neighbor ${n.peer} remote-as ${n.asn}
    neighbor ${n.peer} port ${n.port}
    neighbor ${n.peer} description ${n.description}
    % if node.bgpd.advertisement_timer:
    neighbor ${n.peer} advertisement-interval 1${node.bgpd.advertisement_timer}
    %endif 
    % if n.ebgp_multihop:
    neighbor ${n.peer} ebgp-multihop
    % endif
    <%block name="neighbor"/>
% endfor
% for af in node.bgpd.address_families:
    % if af.name != 'ipv4':
    address-family ${af.name}
    % endif
    % for net in af.networks:
    network ${net.with_prefixlen}
    % endfor
    % for r in af.redistribute:
    redistribute ${r}
    % endfor
    % for n in af.neighbors:
    neighbor ${n.peer} activate
        % if n.nh_self:
    neighbor ${n.peer} ${n.nh_self}
        % endif
    % if n.asn in node.bgpd.communities.keys():
    neighbor ${n.peer} route-map ${n.node}_RMAP_IN in
    %if node.bgpd.communities[n.asn] != '{}:1336'.format(node.bgpd.asn):
    neighbor ${n.peer} route-map ${n.node}_RMAP_OUT out
    %endif
    % endif
    % endfor
    % if af.name != 'ipv4':
    exit-address-family
    % endif
    !
% endfor
<%block name="router"/>
!
ipv6 prefix-list PREFIX permit ${net.with_prefixlen}
ip community-list 70 permit ${node.bgpd.asn}:1336
ip community-list 70 deny
!
% for n in node.bgpd.neighbors:
    % if n.asn in node.bgpd.communities.keys():
route-map ${n.node}_RMAP_IN permit 10
    set community ${node.bgpd.communities[n.asn]}
!
    % endif
    %if node.bgpd.communities[n.asn] != '{}:1336'.format(node.bgpd.asn):
route-map ${n.node}_RMAP_OUT permit 10
    match ipv6 address prefix-list PREFIX
!
route-map ${n.node}_RMAP_OUT permit 20
    match community 70
!
    %endif
% endfor
