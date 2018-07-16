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
% for n in node.bgpd.neighbors:
    no auto-summary
    neighbor ${n.peer} remote-as ${n.asn}
    neighbor ${n.peer} port ${n.port}
    neighbor ${n.peer} description ${n.description}
    neighbor ${n.peer} advertisement-interval ${node.bgpd.advertisement_timer}
    % if n.peer in node.bgpd.communities.keys():
    neighbor ${n.peer} route-map ${n.node}_RMAP out
    % endif
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
    % endfor
    % if af.name != 'ipv4':
    exit-address-family
    % endif
    !
% endfor
<%block name="router"/>
!
% for n in node.bgpd.neighbors:
% if n.peer in node.bgpd.communities.keys():
route-map ${n.node}_RMAP permit 10
 set community ${node.bgpd.communities[n.peer]}
% endif
% endfor
