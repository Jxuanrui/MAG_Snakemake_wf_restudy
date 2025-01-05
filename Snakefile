# -*- coding: utf-8  # 设置文件编码为UTF-8

# This file is part of MAG Snakemake workflow.
# MAG Snakemake workflow is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# MAG Snakemake workflow is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with MAG Snakemake workflow.  If not, see <https://www.gnu.org/licenses/>.

#'''
#   This is a basic framework for recovery and basic quality control of MAGs
#   To visualize the pipeline: snakemake --dag | dot -Tpng > dag.png
#'''
#'''
#   这是一个用于恢复和基本质量控制MAGs（基因组组装）的基本框架
#   要可视化流程，请运行：snakemake --dag | dot -Tpng > dag.png
#'''

__maintainer__ = "Sara Kashaf"  # 维护者名称
__email__ = "sskashaf@ebi.ac.uk"  # 维护者邮箱

import os  # 导入操作系统接口模块
from os.path import join  # 从os.path模块导入join函数，用于路径拼接
import sys  # 导入系统相关参数和函数模块
import glob  # 导入文件名模式匹配模块
import pandas as pd  # 导入pandas库并简写为pd，用于数据处理
import csv  # 导入CSV文件处理模块

configfile: "config.yaml"  # 指定Snakemake的配置文件

# Directory structure  # 目录结构定义
DATA_DIR = "data"  # 数据目录
preprocessing_dir = "00_preprocessing"  # 预处理目录
assembly_dir = "01_assembly"  # 组装目录
binning_dir = "02_binning"  # binning目录
binning_analyses = "03_binning_analyses"  # binning分析目录

if not os.path.exists("logs"):  # 检查是否存在logs目录
    os.makedirs("logs")  # 如果不存在，则创建logs目录

os.system("chmod +x scripts/*")  # 给予scripts目录下所有文件执行权限
os.system("chmod +x scripts/plotting/*")  # 给予scripts/plotting目录下所有文件执行权限

# LOAD METADATA  # 加载元数据
df_run = pd.read_csv("runs.txt")  # 读取runs.txt文件到DataFrame
RUN = df_run["Run"]  # 获取Run列的数据

df_coas = pd.read_csv("coassembly_runs.txt", sep="\t")  # 读取coassembly_runs.txt文件，使用制表符分隔
COAS = df_coas["coassembly"]  # 获取coassembly列的数据

all_outfiles = [
     # Figure 2  # 图2相关输出文件
     join(DATA_DIR, preprocessing_dir, "raw_qc/multiqc/raw_multiqc_report.html"),  # 原始质量控制报告
     join(DATA_DIR, preprocessing_dir, "postprocessing_qc/multiqc/post_multiqc_report.html"),  # 后处理质量控制报告
     # Figure 3a  # 图3a相关输出文件
     join(DATA_DIR, "figures/cmseq_plot.png"),  # cmseq绘图
     join(DATA_DIR, "figures/checkm_contam.png"),  # checkm污染评估图
     join(DATA_DIR, "figures/checkm_completeness.png"),  # checkm完整性评估图
     # Figure 3b  # 图3b相关输出文件
     join(DATA_DIR, "figures/dnadiff.png"),  # dnadiff分析图
     # Figure 3c  # 图3c相关输出文件
     join(DATA_DIR, "figures/gtdb_bacteria.png"),  # GTDB细菌分类图
     # Figure 4  # 图4相关输出文件
     join(DATA_DIR, "figures/perassemb_perref.png")  # 每个组装与参考的比对图
]

rule all:  # 定义Snakemake的all规则，指定最终目标
   input: all_outfiles  # all规则的输入为all_outfiles列表中的所有文件（当您运行 Snakemake 时，它会从 rule all 开始，查看 all_outfiles 中列出的所有文件，并确定这些文件是否已经存在或需要重新生成。如果某些文件不存在，Snakemake 会查找生成这些文件所需的规则，并递归地执行这些规则的依赖项，直到所有目标文件都被生成）

include: "modules/sra_download.Snakefile"  # 包含sra_download模块的Snakefile
include: "modules/preprocessing.Snakefile"  # 包含预处理模块的Snakefile
include: "modules/coas.Snakefile"  # 包含联合组装模块的Snakefile
include: "modules/assembly.Snakefile"  # 包含组装模块的Snakefile
include: "modules/binning.Snakefile"  # 包含binning模块的Snakefile
include: "modules/refine.Snakefile"  # 包含精炼模块的Snakefile
include: "modules/dRep_GTDB.Snakefile"  # 包含dRep_GTDB模块的Snakefile
include: "modules/framework.Snakefile"  # 包含框架模块的Snakefile
include: "modules/refine_coas.Snakefile"  # 包含联合组装精炼模块的Snakefile
include: "modules/cmseq.Snakefile"  # 包含cmseq模块的Snakefile
include: "modules/dnadiff.Snakefile"  # 包含dnadiff模块的Snakefile
