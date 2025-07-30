#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月30日 星期三 22时57分40秒
# Last modified at 2025年07月30日 星期三 23时34分29秒

ans=(
	# find JetBrainsMono-2.304  -type f | sort -f | xargs sha256sum
	"\
33f99c94ef0a0909d7584a5d4bde1fb9b1630daa620f5a788c28c43327e79412  JetBrainsMono-2.304/AUTHORS.txt
4039d5ce0ed225bf9c8b2c8c6436290ae2f356b7e90d70fa666227238324aa3b  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-BoldItalic.ttf
5590990c82e097397517f275f430af4546e1c45cff408bde4255dad142479dcb  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-Bold.ttf
ec3a860fa87d0a3b1451277d1c2f3072f5ba19d2367aec54f7169d5710872610  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-ExtraBoldItalic.ttf
8e501d3a6a883e83ea4f7852804fb0894cebdd67751bb1006b37a476cef34cd6  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-ExtraBold.ttf
3c7fee57538f18b61cc5f0784a8133fe5ee95feb41f633e8f6f7ef609e6207ec  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-ExtraLightItalic.ttf
8391e7ec13e8ba758c1838f56bccd973228ccf4dc74aa5bffe9525b9147b12f8  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-ExtraLight.ttf
9d0a1f7a708e6af183f1193b7e81d40da294f5c67682c085d8401c60aac8ded4  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-Italic.ttf
18ffadb91fa711b45feae027ddfd561e7f97ace805ec4baf9905046cf450befb  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-LightItalic.ttf
60c18d7dd58d81b3bbd12e8ce32744a8771bfe2b5280574082b0eaed46c60d24  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-Light.ttf
4477fda6bd472ef96b11bc1083370f7fc3ff427bdc807e682ced5819e3dee9df  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-MediumItalic.ttf
31c92d01a8a08528b718a43addf0ad3df0af2ca4b7b3290a452f70f358e14d3d  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-Medium.ttf
6c2716f2e85101f4109a8c16916061eb38176b3b10342834858d6221ec2fda1b  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-BoldItalic.ttf
0198e841824025f8876e5c297f0b9b497ee8d6eb9969710a3328e1303f996ec3  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-Bold.ttf
0f386a0bd99bb2d41079fe438725b471b49a48e355b8d57399b7a6e8e1c63da6  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-ExtraBoldItalic.ttf
673f0209e5428e5f73a159df85806f8a5bf7f83316bb9554427a3eb877ee0cb7  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-ExtraBold.ttf
7d5c8b4d42d7a4c268398c066f71b606f7f071864e73740c99a58838c55efde5  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-ExtraLightItalic.ttf
4ffddcd8bbebbdd8c066bd66ea32aa7995fdb7bc626777b1a8948074c85a2e9f  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-ExtraLight.ttf
c7392a134293e1af1d36fbf04940dd844f632afbf97f8325d1591d3af5096cb8  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-Italic.ttf
edbf41bed6eea37ae5d6ccd4353158d5bef140f1d078408ea20e4e599622b895  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-LightItalic.ttf
8bf1b1733d0a32c4ada2451deb1bd36e6945be3bf2bf2ba80c2be7c95e57f230  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-Light.ttf
2a5c56075d7bec1d54fa9761d5eeef7d4267e134d86962011425503b27e61ddd  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-MediumItalic.ttf
44099e1efefba55637e0abbbf8dd3f526e59523345888a257bb01d39df4af74c  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-Medium.ttf
fb3b2575d7b0657359707993288f12a7360344d39387bb26050e276d61f6bd2a  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-Regular.ttf
f813544badbdab235b1f2f9933bb978be0a87cbde0133aaa05b80a84a7d94c22  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-SemiBoldItalic.ttf
2c5dc6725fdbb0dccf65adceb38fdcd95e5fc8a5b74d5c150e38a5faa02a8945  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-SemiBold.ttf
58812240c633523eb930ac6ce86f392f4e2b5ad920549278d1758d70af972ad7  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-ThinItalic.ttf
1acb532f18726155022a1e8b717bf7bde3eb30e9e064ccc6d17b3d91e95204b0  JetBrainsMono-2.304/fonts/ttf/JetBrainsMonoNL-Thin.ttf
a0bf60ef0f83c5ed4d7a75d45838548b1f6873372dfac88f71804491898d138f  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-Regular.ttf
3b3000507a7285872395ddbb4e53a28f07910dbf494fb0d5e1421dd60b5d8436  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-SemiBoldItalic.ttf
1b3bfa1ed5665a4ce3f9feb68d2d4e40e70bf8b4b7d9a3edd418f321b4e166a0  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-SemiBold.ttf
ebcdd13119b6beb7457e2f76b31094cb8cf1108e567030f8402b24dde018e76a  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-ThinItalic.ttf
0756e8e8cf1d65fa7519776764479b3973efb15af4f419d5d7274dc27ae1b702  JetBrainsMono-2.304/fonts/ttf/JetBrainsMono-Thin.ttf
f115aaa12113718c02ce72864fe6823b87241bc23d3e44cf1220155f861063f2  JetBrainsMono-2.304/fonts/variable/JetBrainsMono-Italic[wght].ttf
662a196d58f1183bf2d77428b6d5283fe3f45161ab021bea4036bc98e5cac016  JetBrainsMono-2.304/fonts/variable/JetBrainsMono[wght].ttf
3a013466c0eee979fb9d42c2d7a8887cd3645dc8b897cfc5b71781cf982efc5a  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-BoldItalic.woff2
c503cc5ec5f8b2c7666b7ecda1adf44bd45f2e6579b2eba0fc292150416588a2  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-Bold.woff2
67718afd5e93925277efb878127107f0ff668059ef5fd799fb31ed12aaae7a96  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-ExtraBoldItalic.woff2
88097a36a292c145a14394f1fd5133f76b9a3d6fdb133834b2c94a3db61dd39a  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-ExtraBold.woff2
c43d0dd87523c65879334d43651d3fb1815ca1d18d27507356e6704322d63b79  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-ExtraLightItalic.woff2
e7964fc553a794d00167f168dc174fdd19b083c30ad213bfc2e6a95876912a44  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-ExtraLight.woff2
cb6a1b246318ed3885d7dffa14a2609297fe80e9b8e500bea33b52fa312a36a4  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-Italic.woff2
49c50b344b458c1322d859f4f0d9db7f770533c1dbdab31defa0987c29925b9b  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-LightItalic.woff2
43eb798d59b557c3d87c1402ce684b3fda1ad66bf7ec8021b0a43dc31ad9c572  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-Light.woff2
1c9b7a62ee6c3f77c82982a3d0ab7ead8805f5e67ccfc1942037fc65f398f22b  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-MediumItalic.woff2
086c48dfbea9ddaff1320f7e09399b8e2924e88ce67453721255db3bdbb5a353  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-Medium.woff2
a9cb1cd82332b23a47e3a1239d25d13c86d16c4220695e34b243effa999f45f2  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-Regular.woff2
07daacf7fc1956b5b68d902ab4763a062b196a3665d713e54bff066c667c0674  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-SemiBoldItalic.woff2
918edad542a1da608fd2ba8daebaff9ac802309103fe760eed465b8b4e47faf1  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-SemiBold.woff2
c261d07880deb91518e190c19816ddc93a69bf4539b8486cad316b6ed59a065d  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-ThinItalic.woff2
01c7c4cd01380e75fb1b5ff9900508afcd89a83d0b0e6f70e96ede53183ab53a  JetBrainsMono-2.304/fonts/webfonts/JetBrainsMono-Thin.woff2
30f0c136e3c88e422d0791acd97238870f9054a9729bc34cf2ff0d4ed8cac4ad  JetBrainsMono-2.304/OFL.txt\
"
	# find Fira_Code_v6.2 -type f | sort -f | xargs sha256sum
	"\
12d0b7ebcbb31c7e9b8fd61ceca106dca21dd8ee8f9ae65d2d81d933d5134736  Fira_Code_v6.2/fira_code.css
510d4a5c26c9c0c17348316fd927923d6e30613e1c06f06bfb99fccf07e31245  Fira_Code_v6.2/README.txt
0fcab75b1a3093afb78cea84f728627feae9aa14ae500402f186333ba7c98609  Fira_Code_v6.2/specimen.html
41f6554e845e2f5b70adad3950122334b866aac436793b7742ade600067701be  Fira_Code_v6.2/ttf/FiraCode-Bold.ttf
c146c9a7a61914f9f5a47d24c199c50c8f143f5710b93efd3a3953af50816443  Fira_Code_v6.2/ttf/FiraCode-Light.ttf
97091f90623661fb4f7979c10d188f30f4806d8ce326b0bc8d1acc79dcc20d8f  Fira_Code_v6.2/ttf/FiraCode-Medium.ttf
5992ab9640e2df491b2f609467b1de60e8bc39b2c28db184342a0592d98f6117  Fira_Code_v6.2/ttf/FiraCode-Regular.ttf
4fe2df1cea543281e8ec0fa512d1b493eacb859cf62bc7a84886daa89268b3f3  Fira_Code_v6.2/ttf/FiraCode-Retina.ttf
500c74eec6249b06d49aef922dd3e8fc754c70c3b3f7791cd7b1a09ca9a26140  Fira_Code_v6.2/ttf/FiraCode-SemiBold.ttf
04149681350f161aca538858b88d17443c586cacca83c165939a13423fe91a26  Fira_Code_v6.2/variable_ttf/FiraCode-VF.ttf
d778c19803c672d294663e9283c7b752cc125ab266f0ddb8e53b039da92caf67  Fira_Code_v6.2/woff2/FiraCode-Bold.woff2
e3aa3db06cfb19dfc0b0f1f38355add3e8d1ef45d3af39ce95d9ca7d96114e6c  Fira_Code_v6.2/woff2/FiraCode-Light.woff2
0e04bafb989ea46e840a581e49557b229662a00021493a5744c595d0882adf28  Fira_Code_v6.2/woff2/FiraCode-Medium.woff2
a6ce59520b90e15d7062ffef214f94c8add5a4085c0bbb1683602ef227a4d1fe  Fira_Code_v6.2/woff2/FiraCode-Regular.woff2
d16779aa6dfc7c4effe686ece5bdf4b1356a7352167e37fa256f596a9d428f11  Fira_Code_v6.2/woff2/FiraCode-SemiBold.woff2
408e876a202f15ea6ee307a70a65cf40ceb222c589a0b17e0a3a371db96dd49f  Fira_Code_v6.2/woff2/FiraCode-VF.woff2
3760314a6100f7c06569d7dbcb63c6be76e4c758d3119c0a1f4d0f2dfd64b59a  Fira_Code_v6.2/woff/FiraCode-Bold.woff
ece6bdf6821d1c41a5ef8ee901661bf8df0809d074fb3992cd1349b74d4e1b68  Fira_Code_v6.2/woff/FiraCode-Light.woff
91f1c9c3eb82cca58221333684cf022e9169849c510158e9f162929d15286b66  Fira_Code_v6.2/woff/FiraCode-Medium.woff
e4b5a20d572b7f718d64c884e4e48cb7e45303ab50722011469ee2e1964bff6d  Fira_Code_v6.2/woff/FiraCode-Regular.woff
f7f09d47f416331a739641d5c1222fc989e43e7aa254a9fe1977cead0133616c  Fira_Code_v6.2/woff/FiraCode-SemiBold.woff
6c9de3511811ecb6992835f2a8cc2623cb2a41b47823d954278150bb73c53eaf  Fira_Code_v6.2/woff/FiraCode-VF.woff\
"
	# find lxgw-wenkai-v1.520  -type f | sort -f | xargs sha256sum
	"\
d114a0ef770387f141d4cf21ee564eb05bed7de497f63c296f5cc4a556562181  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/LXGWWenKai-Light.ttf
d7a98ff8898087f019e5617d026c3f83158926ec9e657184920dc4bc7d7d97c8  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/LXGWWenKai-Medium.ttf
b76abb4bbccdd4167f5202f92bf651072e841037ae18ce205c74b20c36a4b286  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/LXGWWenKaiMono-Light.ttf
ba4c68ad8420ebddcdcb3328aac6585681beb0d5e14bc51eaf2f84d461719eb4  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/LXGWWenKaiMono-Medium.ttf
ee9faa6479c5b2434f9bceca8e2e7b643f699f4f3d067aac9609261e07c6be61  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/LXGWWenKaiMono-Regular.ttf
8d6ba638ac9553413354cfaab97637c1cd778444e259441ea1e5f8fb2c697fba  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/LXGWWenKai-Regular.ttf
5c0f0d98a8b71a401063c9a9e814e608fef6824fefab0c2ab73fe0955a5551b1  lxgw-wenkai-v1.520/lxgw-wenkai-v1.520/OFL.txt\
"
)
target=(
	"JetBrainsMono-2.304"
	"Fira_Code_v6.2"
	"lxgw-wenkai-v1.520"
)

cd "$HOME/.fonts/"
for ((i=0; i<${#target[@]}; i ++)); do
	res=`find "${target[i]}" -type f | sort -df | xargs sha256sum`
	if [[ "$res" != "${ans[i]}" ]]; then
cat << FAILURE
	hash-test-failed: $i
	res =
$res
	ref =
${ans[i]}
FAILURE
	exit 1
	fi
done
