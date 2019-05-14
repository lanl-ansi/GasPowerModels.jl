function mpc = case14

%CASE14    Power flow data for IEEE 14 bus test case.
%   Please see CASEFORMAT for details on the case file format.
%   This data was converted from IEEE Common Data Format
%   (ieee14cdf.txt) on 15-Oct-2014 by cdf2matp, rev. 2393
%   See end of file for warnings generated during conversion.
%
%   Converted from IEEE CDF file from:
%       http://www.ee.washington.edu/research/pstca/
%
%  08/19/93 UW ARCHIVE           100.0  1962 W IEEE 14 Bus Test Case

%   MATPOWER

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	3	0.0		0.0		0.0	0.0		1	1.06	0.0		0	1	1.06	0.94
	2	2	43.4	25.4	0.0	0.0		1	1.045	-4.98	0	1	1.06	0.94
	3	2	188.4	38.0	0.0	0.0		1	1.01	-12.72	0	1	1.06	0.94
	4	1	95.6	-7.8	0.0	0.0		1	1.019	-10.33	0	1	1.06	0.94
	5	1	15.2	3.2		0.0	0.0		1	1.02	-8.78	0	1	1.06	0.94
	6	2	22.4	15.0	0.0	0.0		1	1.07	-14.22	0	1	1.06	0.94
	7	1	0.0		0.0		0.0	0.0		1	1.062	-13.37	0	1	1.06	0.94
	8	2	0.0		0.0		0.0	0.0		1	1.09	-13.36	0	1	1.06	0.94
	9	1	59.0	33.2	0.0	19.0	1	1.056	-14.94	0	1	1.06	0.94
	10	1	18.0	11.6	0.0	0.0		1	1.051	-15.1	0	1	1.06	0.94
	11	1	7.0		3.6		0.0	0.0		1	1.057	-14.79	0	1	1.06	0.94
	12	1	12.2	3.2		0.0	0.0		1	1.055	-15.07	0	1	1.06	0.94
	13	1	27.0	11.6	0.0	0.0		1	1.05	-15.16	0	1	1.06	0.94
	14	1	29.8	10.0	0.0	0.0		1	1.036	-16.04	0	1	1.06	0.94
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	232.4	-16.9	10	0	1.06	100	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
	2	40		42.4	100	-40	1.045	100	1	280	0	0	0	0	0	0	0	0	0	0	0	0;
	3	0		23.4	80	0	1.01	100	1	200	0	0	0	0	0	0	0	0	0	0	0	0;
	6	0		12.2	24	-6	1.07	100	1	100	0	0	0	0	0	0	0	0	0	0	0	0;
	8	0		17.4	24	-6	1.09	100	1	0	0	0	0	0	0	0	0	0	0	0	0	0;
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	2	0.01938	0.05917	0.0528	1		0	0	0		0	1	-60	60;
	1	5	0.05403	0.22304	0.0492	489		0	0	0		0	1	-60	60;
	2	3	0.04699	0.19797	0.0438	552		0	0	0		0	1	-60	60;
	2	4	0.05811	0.17632	0.034	605		0	0	0		0	1	-60	60;
	2	5	0.05695	0.17388	0.0346	614		0	0	0		0	1	-60	60;
	3	4	0.06701	0.17103	0.0128	611		0	0	0		0	1	-60	60;
	4	5	0.01335	0.04211	0		2543	0	0	0		0	1	-60	60;
	4	7	0		0.20912	0		537		0	0	0.978	0	1	-60	60;
	4	9	0		0.55618	0		202		0	0	0.969	0	1	-60	60;
	5	6	0		0.25202	0		445		0	0	0.932	0	1	-60	60;
	6	11	0.09498	0.1989	0		509		0	0	0		0	1	-60	60;
	6	12	0.12291	0.25581	0		395		0	0	0		0	1	-60	60;
	6	13	0.06615	0.13027	0		769		0	0	0		0	1	-60	60;
	7	8	0		0.17615	0		637		0	0	0		0	1	-60	60;
	7	9	0		0.11001	0		1021	0	0	0		0	1	-60	60;
	9	10	0.03181	0.0845	0		1244	0	0	0		0	1	-60	60;
	9	14	0.12711	0.27038	0		376		0	0	0		0	1	-60	60;
	10	11	0.08205	0.19207	0		537		0	0	0		0	1	-60	60;
	12	13	0.22092	0.19988	0		377		0	0	0		0	1	-60	60;
	13	14	0.17093	0.34802	0		289		0	0	0		0	1	-60	60;
];

%%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	3	0.0430292599	20	0;
	2	0	0	3	0.25	20	0;
	2	0	0	3	0.01	40	0;
	2	0	0	3	0.01	40	0;
	2	0	0	3	0.01	40	0;
];

%% bus names
mpc.bus_name = {
	'Bus 1     HV';
	'Bus 2     HV';
	'Bus 3     HV';
	'Bus 4     HV';
	'Bus 5     HV';
	'Bus 6     LV';
	'Bus 7     ZV';
	'Bus 8     TV';
	'Bus 9     LV';
	'Bus 10    LV';
	'Bus 11    LV';
	'Bus 12    LV';
	'Bus 13    LV';
	'Bus 14    LV';
};


%column_names%	f_bus	t_bus	br_r	br_x	br_b	rate_a	rate_b	rate_c	tap	shift	br_status	angmin	angmax	construction_cost
mpc.ne_branch = [
2	4	0.05811	0.17632	0.034	605.23	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
4	9	0		0.55618	0		202.02	0.0	0.0	0.969	0	1	-60.0	60.0	7.226588437e6
6	12	0.12291	0.25581	0		395.9	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
2	5	0.05695	0.17388	0.0346	614.09	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
2	3	0.04699	0.19797	0.0438	552.22	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
1	5	0.05403	0.22304	0.0492	489.61	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
7	9	0		0.11001	0		1021.36	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
4	5	0.01335	0.04211	0		2543.49	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
6	11	0.09498	0.1989	0		509.77	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
6	13	0.06615	0.13027	0		769.05	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
4	7	0		0.20912	0		537.3	0.0	0.0	0.978	0	1	-60.0	60.0	7.226588437e6
12	13	0.22092	0.19988	0		377.15	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
13	14	0.17093	0.34802	0		289.79	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
1	2	0.01938	0.05917	0.0528	1804.6	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
10	11	0.08205	0.19207	0		537.96	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
7	8	0		0.17615	0		637.87	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
9	10	0.03181	0.0845	0		1244.45	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
3	4	0.06701	0.17103	0.0128	611.69	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
9	14	0.12711	0.27038	0		376.08	0.0	0.0	1		0	1	-60.0	60.0	7.226588437e6
5	6	0		0.25202	0		445.84	0.0	0.0	0.932	0	1	-60.0	60.0	7.226588437e6

];


%column_names%  consumer  heat_rate_quad_coeff   heat_rate_linear_coeff   heat_rate_constant_coeff
mpc.gen_gas = [
	-1	0   0             0;
	4	0	1392087.5     0;
	10012	0	60138.1944444 0;
	-1	0	0	          0;
	-1	0	0	          0;
];

% Warnings from cdf2matp conversion:
%
% ***** check the title format in the first line of the cdf file.
% ***** Qmax = Qmin at generator at bus    1 (Qmax set to Qmin + 10)
% ***** MVA limit of branch 1 - 2 not given, set to 0
% ***** MVA limit of branch 1 - 5 not given, set to 0
% ***** MVA limit of branch 2 - 3 not given, set to 0
% ***** MVA limit of branch 2 - 4 not given, set to 0
% ***** MVA limit of branch 2 - 5 not given, set to 0
% ***** MVA limit of branch 3 - 4 not given, set to 0
% ***** MVA limit of branch 4 - 5 not given, set to 0
% ***** MVA limit of branch 4 - 7 not given, set to 0
% ***** MVA limit of branch 4 - 9 not given, set to 0
% ***** MVA limit of branch 5 - 6 not given, set to 0
% ***** MVA limit of branch 6 - 11 not given, set to 0
% ***** MVA limit of branch 6 - 12 not given, set to 0
% ***** MVA limit of branch 6 - 13 not given, set to 0
% ***** MVA limit of branch 7 - 8 not given, set to 0
% ***** MVA limit of branch 7 - 9 not given, set to 0
% ***** MVA limit of branch 9 - 10 not given, set to 0
% ***** MVA limit of branch 9 - 14 not given, set to 0
% ***** MVA limit of branch 10 - 11 not given, set to 0
% ***** MVA limit of branch 12 - 13 not given, set to 0
% ***** MVA limit of branch 13 - 14 not given, set to 0
