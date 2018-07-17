"""This module holds the configuration generators for routing daemons
that can be used in a router."""
from .base import BasicRouterConfig, RouterConfig
from .zebra import Zebra
from .ospf import OSPF, OSPFArea
from .ospf6 import OSPF6
from .bgp import BGP, AS, iBGPFullMesh, bgp_peering, bgp_fullmesh, ebgp_session,\
                set_community
from .radvd import RADVD, AdvPrefix, AdvRDNSS
from .iptables import IPTables, IP6Tables
from .sshd import SSHd
from .pimd import PIMD

__all__ = ['BasicRouterConfig', 'Zebra', 'OSPF', 'OSPF6', 'OSPFArea', 'BGP', 'AS',
           'iBGPFullMesh', 'bgp_peering', 'RouterConfig', 'bgp_fullmesh',
           'ebgp_session', 'IPTables', 'IP6Tables', 'SSHd', 'RADVD', 'AdvPrefix',
           'AdvRDNSS', 'PIMD', 'set_community']
