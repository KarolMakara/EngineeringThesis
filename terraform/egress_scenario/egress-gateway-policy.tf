# resource "kubernetes_manifest" "egress_policy" {
#   manifest = {
#     apiVersion = "cilium.io/v2"
#     kind       = "CiliumEgressGatewayPolicy"
#     metadata = {
#       name      = "egress-sample"
#       namespace = "iperf"
#     }
#     spec = {
#       destinationCIDRs = ["0.0.0.0/0"] # ip of destination of egress traffic
#       selectors = [
#         {
#           podSelector = {}
#         }
#       ]
#       egressGateway = {
#         nodeSelector = {
#           matchLabels = {
#             "egress-node" = "true"
#           }
#         }
#       }
#     }
#   }
# }
