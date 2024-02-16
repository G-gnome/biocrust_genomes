library(dplyr)
library(ggplot2)
library(ggtree)
library(viridis)
library(phytools)
library(ggnewscale)
library(ggtreeExtra)

# Read the tree file
tree <- read.tree("aligments.fasta.treefile")

# Root the tree
rooted_tree <- root(tree, outgroup = "CMW7063")

# Drop the specified tip
straintree <- drop.tip(rooted_tree, "CMW7063")

plot(straintree)

ggsave("Coniochaeta_JDC7_tree.png", straintree, width = 25, height = 45)