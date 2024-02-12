library(dplyr)
library(ggplot2)
library(ggtree)
library(viridis)
library(phytools)
library(ggnewscale)
library(ggtreeExtra)

# Read the tree file
tree <- read.tree("modified.treefile")

# Root the tree
rooted_tree <- root(tree, outgroup = "Chaetosphaeria_ciliata")

# Drop the specified tip
straintree <- drop.tip(rooted_tree, "Chaetosphaeria_ciliata")


# Check the structure of straintree
str(straintree)

# Based on the structure of straintree, identify the correct attribute for bootstrap values

p1 <- ggtree(straintree, layout="rectangular",size=1,aes(color=as.numeric(label))) +
  scale_color_gradient("Bootstrap", low = "green", high = "black", limits=c(0,100)) + new_scale_color() +
  #geom_nodelab(label= straintree$node.label,size=2, vjust = 0.5, hjust = 0.5, node = "internal", nudge_x = 0.5) +
  geom_tiplab(size=5, color="black") + theme(legend.position = "bottom")  + 
  scale_y_continuous(expand=c(0.01,0.07,0.01,0.07)) +
  scale_x_continuous(limits=c(0, .22))


plot(p1)

# Save the plot to an image file
ggsave("Coniochaeta_JDC7_tree.png", p1, width = 12.5, height = 10)