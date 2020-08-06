function mgc = belgian-ne-opf

%% required global data
mgc.gas_molar_mass = 0.0185674; % kg/mol
mgc.gas_specific_gravity = 0.6;
mgc.specific_heat_capacity_ratio = 1.4; % unitless
mgc.temperature = 281.15; % K
mgc.compressibility_factor = 0.8; % unitless
mgc.standard_density = 1.0; %
mgc.units = 'si';

%% optional global data (that was either provided or computed based on required global data)
mgc.energy_factor = 2.61590529e-8;
mgc.sound_speed = 317.3536522338898; % m/s
mgc.R = 8.314; % J/(mol K)
mgc.base_pressure = 8000000; % Pa
mgc.base_length = 5000; % m
mgc.base_flow = 535.8564814814815; % kg/s
mgc.is_per_unit = 0;

%% junction data
% id  p_min  p_max  p_nominal  junction_type  status  pipeline_name  edi_id  lat  lon
mgc.junction = [
  1       0        7700000  0        0  1  'belgian'  1       0  0
  2       0        7700000  0        0  1  'belgian'  2       0  0
  3       3000000  8000000  3000000  0  1  'belgian'  3       0  0
  4       0        8000000  0        0  1  'belgian'  4       0  0
  5       0        7700000  0        0  1  'belgian'  5       0  0
  6       3000000  8000000  3000000  0  1  'belgian'  6       0  0
  7       3000000  8000000  3000000  0  1  'belgian'  7       0  0
  8       5000000  6620000  5000000  0  1  'belgian'  8       0  0
  9       0        6620000  0        0  1  'belgian'  9       0  0
  10      3000000  6620000  3000000  0  1  'belgian'  10      0  0
  11      0        6620000  0        0  1  'belgian'  11      0  0
  12      0        6620000  0        0  1  'belgian'  12      0  0
  13      0        6620000  0        0  1  'belgian'  13      0  0
  14      0        6620000  0        0  1  'belgian'  14      0  0
  15      0        6620000  0        0  1  'belgian'  15      0  0
  16      5000000  6620000  5000000  0  1  'belgian'  16      0  0
  17      0        6620000  0        0  1  'belgian'  17      0  0
  18      0        6300000  0        0  1  'belgian'  18      0  0
  19      0        6620000  0        0  1  'belgian'  19      0  0
  20      2500000  6620000  2500000  0  1  'belgian'  20      0  0
  81      0        6620000  0        0  1  'belgian'  81      0  0
  171     0        6620000  0        0  1  'belgian'  171     0  0
  100017  0        6620000  0        0  1  'belgian'  100017  0  0
  200008  0        6620000  0        0  1  'belgian'  200008  0  0
  300008  0        6620000  0        0  1  'belgian'  300008  0  0
];

%% pipe data
% id  fr_junction  to_junction  diameter  length  friction_factor  p_min  p_max  status
mgc.pipe = [
  1    1    2   0.89    4000   0.00703703702644929   0        7700000  1
  2    1    2   0.89    4000   0.00703703702644929   0        7700000  1
  3    2    3   0.89    6000   0.00703703702606137   0        8000000  1
  4    2    3   0.89    6000   0.00703703702606137   0        8000000  1
  5    3    4   0.89    26000  0.007037037026061373  0        8000000  1
  6    5    6   0.5901  43000  0.007588747325145461  0        8000000  1
  7    6    7   0.5901  29000  0.007588747333947063  3000000  8000000  1
  8    7    4   0.5901  19000  0.007588747302261286  0        8000000  1
  9    4    14  0.89    55000  0.007037037024121784  0        8000000  1
  12   9    10  0.89    20000  0.00703703702800096   0        6620000  1
  13   9    10  0.3955  20000  0.008190765797887557  0        6620000  1
  14   10   11  0.89    25000  0.007037037024121785  0        6620000  1
  15   10   11  0.3955  25000  0.008190765949521473  0        6620000  1
  17   12   13  0.89    40000  0.007037037024121785  0        6620000  1
  18   13   14  0.89    5000   0.007037037026061373  0        6620000  1
  19   14   15  0.89    10000  0.007037037026061371  0        6620000  1
  20   15   16  0.89    25000  0.007037037024121785  0        6620000  1
  21   11   17  0.3955  10500  0.008190765866122817  0        6620000  1
  23   18   19  0.3155  98000  0.008562967980940269  0        6620000  1
  24   19   20  0.3155  6000   0.00856296757052686   0        6620000  1
  101  81   9   0.89    5000   0.007037037026061373  0        6620000  1
  111  81   9   0.3955  5000   0.008190765873704516  0        6620000  1
  221  171  18  0.3155  26000  0.008562967878336915  0        6620000  1
];

%% compressor data
% id  fr_junction  to_junction  c_ratio_min  c_ratio_max  power_max  flow_min  flow_max  inlet_p_min  inlet_p_max  outlet_p_min  outlet_p_max  status  operating_cost  directionality
mgc.compressor = [
  10      8    300008  1  2  1000000000  -5358564.814814815  5358564.814814815  0  6620000  0  6620000  1  10  2
  11      8    200008  1  2  1000000000  -5358564.814814815  5358564.814814815  0  6620000  0  6620000  1  10  2
  22      17   100017  1  2  1000000000  -5358564.814814815  5358564.814814815  0  6620000  0  6620000  1  10  2
  100000  171  100017  1  2  1000000000  -5358564.814814815  5358564.814814815  0  6620000  0  6620000  1  10  2
  100001  81   200008  1  2  1000000000  -5358564.814814815  5358564.814814815  0  6620000  0  6620000  1  10  2
  100002  81   300008  1  2  1000000000  -5358564.814814815  5358564.814814815  0  6620000  0  6620000  1  10  2
];

%% short_pipe data
% 
mgc.short_pipe = [
];

%% resistor data
% 
mgc.resistor = [
];

%% valve data
% 
mgc.valve = [
];

%% receipt data
% id  junction_id  injection_min  injection_max  injection_nominal  is_dispatchable  status
mgc.receipt = [
  1      1   126.2880555555556  126.2880555555556  126.2880555555556  0  1
  2      2   97.22222222222223  97.22222222222223  97.22222222222223  0  1
  5      5   32.57768518518519  32.57768518518519  32.57768518518519  0  1
  8      8   254.7685185185185  254.7685185185185  254.7685185185185  0  1
  13     13  13.88888888888889  13.88888888888889  13.88888888888889  0  1
  14     14  11.11111111111111  11.11111111111111  11.11111111111111  0  1
  10001  1   0                  11574074.07407407  0                  1  1
  10002  2   0                  11574074.07407407  0                  1  1
  10005  5   0                  11574074.07407407  0                  1  1
  10008  8   0                  11574074.07407407  0                  1  1
  10013  13  0                  11574074.07407407  0                  1  1
  10014  14  0                  11574074.07407407  0                  1  1
];

%% delivery data
% id  junction_id  withdrawal_min  withdrawal_max  withdrawal_nominal  is_dispatchable  status
mgc.delivery = [
  3      3   45.34722222222223  45.34722222222223  45.34722222222223  0  1
  4      4   0.0                11574074.07407407  0.0                1  1
  6      6   46.68981481481482  46.68981481481482  46.68981481481482  0  1
  7      7   60.83333333333334  60.83333333333334  60.83333333333334  0  1
  10     10  73.66898148148148  73.66898148148148  73.66898148148148  0  1
  12     12  24.53703703703704  24.53703703703704  24.53703703703704  0  1
  15     15  79.25925925925927  79.25925925925927  79.25925925925927  0  1
  16     16  180.7407407407407  180.7407407407407  180.7407407407407  0  1
  19     19  2.569444444444445  2.569444444444445  2.569444444444445  0  1
  20     20  22.21064814814815  22.21064814814815  22.21064814814815  0  1
  10012  12  0.0                11574074.07407407  0.0                1  1
];

%% ne_pipe data
% id  fr_junction  to_junction  diameter  length  friction_factor  p_min  p_max  status  construction_cost
mgc.ne_pipe = [
  16  11  12  0.89  42000  0.007037037028388877  0  6620000  1  1.0e7
];

%% price_zone data
%column_names% id  cost_q_1  cost_q_2  cost_q_3  cost_p_1  cost_p_2  cost_p_3  min_cost  constant_p
mgc.price_zone = [
  1  0.0  0.0  0.0  8.85e-24  -1.35e-10  0.0     0.0  175.0
  2  0.0  0.0  0.0  0.0        1.05e-12  794.37  0.0  600.0
];

%% junction data (extended)
%column_names% price_zone
mgc.junction_data = [
  -1
  1
  2
  -1
  1
  2
  -1
  1
  2
  -1
  1
  2
  -1
  1
  2
  -1
  1
  2
  -1
  1
  2
  -1
  1
  2
  -1
];

%% ne_compressor data
% 
mgc.ne_compressor = [
];

end
