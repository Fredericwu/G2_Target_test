#!/bin/bash
#变量

name="target1"
iqn1="iqn.2020-07.com.example:vteltarget1"
iqn2="iqn.2020-07.com.example:vteltarget11"
pt1="pt1"
pt2="pt2"
dir1="/root/vtelTest/targetTest/test/"
dir2="/root/vtelTest/targetTest/test/orion/vplx"
pt1_IP="10.203.1.50:3260"
pt2_IP="10.203.1.52:3260"


#crm 创建target命令
crm conf primitive $name iSCSITarget params iqn=$iqn1 implementation=lio-t portals=$pt1_IP op start timeout=50 stop timeout=40 op monitor interval=15 timeout=40 meta target-role=Started
crm conf colocation col_target1_pt1 inf: $name $pt1
crm cof order or_target1_pt1 $pt1 $name
crm cof save crmCreate

#crm 修改target iqn命令
crm conf set $name.iqn $iqn2
crm cof save crmMiqn


#crm 修改target portal命令
crm conf set $name.portals $pt2_IP
crm conf del col_target1_pt1
crm conf del or_target1_pt1
crm conf colocation col_target1_pt2 inf: $name $pt2
crm cof order or_target1_pt2 $pt2 $name
crm cof save crmMpt

#crm stop target 命令
crm res stop $name
crm cof save crmStop

#crm start target命令
crm res start $name
crm cof save crmStart


#crm 删除 target命令
crm res stop $name
crm conf del $name
crm cof save crmD



#vtel命令
#python3 vtel.py iscsi pt c pt1 -ip 10.203.1.50
#python3 vtel.py iscsi pt c pt2 -ip 10.203.1.52

#vtel 创建target 命令
cd $dir2
python3 vtel.py iscsi target c $name -iqn $iqn1 -portal $pt1
crm cof save $dir1/vtelC




#vtel 修改target iqn命令
python3 vtel.py iscsi target m $name -iqn $iqn2
crm cof save $dir1/vtelMiqn




#vtel 修改target portal命令
python3 vtel.py iscsi target m $name -pt $pt2
crm cof save $dir1/vtelMpt




#vtel stop target 命令
python3 vtel.py iscsi sync 
python3 vtel.py iscsi target stop $name
crm cof save $dir1/vtelStop




#vtel start target命令
python3 vtel.py iscsi target start $name
crm cof save $dir1/vtelStart




#vtel 删除 target命令
python3 vtel.py iscsi target delete $name
crm cof save $dir1/vtelD
cd $dir1



#diff命令，将结果追加到diff.txt
diff crmCreate vtelC > diff.txt
diff crmMiqn vtelMiqn >> diff.txt
diff crmMpt vtelMpt >> diff.txt
diff crmStop vtelStop >> diff.txt
diff crmStart vtelStart >> diff.txt
diff crmD vtelD >> diff.txt



