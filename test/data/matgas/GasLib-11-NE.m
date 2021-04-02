function mgc = GasLib_11_GPF

%% required global data
mgc.gas_molar_mass = 0.0185674;  % kg/mol
mgc.gas_specific_gravity = 0.6411;
mgc.specific_heat_capacity_ratio = 1.2841;  % unitless
mgc.temperature = 283.1500;  % K
mgc.compressibility_factor = 1.0000;  % unitless
mgc.units = 'si';
mgc.standard_density = 0.785;

%% optional global data (that was either provided or computed based on required global data)
mgc.energy_factor = 2.3286259e-12;
mgc.sound_speed = 356.0719;  % m/s
mgc.R = 8.3140;  % J/(mol K)
mgc.base_pressure = 4000000.0000;  % Pa
mgc.base_length = 5000.0000;  % m
mgc.base_flow = 11233.68623022485
mgc.is_per_unit = 1;

%% junction data
% id    p_min    p_max    p_nominal    junction_type    status    pipeline_name    edi_id    lat    lon
mgc.junction = [
    1     1.0000    1.7500    1.375    0    1    'GasLib_11'    1     600      300
    2     1.0000    1.7500    1.375    0    1    'GasLib_11'    2     600     -100
    3     1.0000    1.7500    1.375    0    1    'GasLib_11'    3     400      0
    4     1.0000    1.5000    1.375    0    1    'GasLib_11'    4     1141     141
    5     1.0000    1.7500    1.375    0    1    'GasLib_11'    5     800      0
    6     1.0000    1.7500    1.375    0    1    'GasLib_11'    6     600      100
    7     1.0000    1.7500    1.375    0    1    'GasLib_11'    7     1000     0
    8     1.0000    1.5000    1.375    0    1    'GasLib_11'    8     1141    -141
    9     1.0000    1.7500    1.375    0    1    'GasLib_11'    9     200      0
    10    1.0000    1.7500    1.375    0    1    'GasLib_11'    10    600     -300
    11    1.0000    1.7500    1.375    0    1    'GasLib_11'    11    0        0
];

%% pipe data
% id    fr_junction    to_junction    diameter    length    friction_factor    p_min    p_max    status    is_bidirectional
mgc.pipe = [
    1    6     5    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
    2    10    2    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
    3    3     6    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
    5    2     5    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
    6    7     4    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
    7    7     8    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
    8    11    9    0.5000    11.0000    0.0026    1.0000    1.7500    1    1
];

%% compressor data
% id    fr_junction    to_junction    c_ratio_min    c_ratio_max    power_max    flow_min    flow_max    inlet_p_min    inlet_p_max    outlet_p_min    outlet_p_max    status    operating_cost    directionality
mgc.compressor = [
    1    5    7    0.0000    1.7500    16127.5033    -0.0058    0.0058    1.0000    1.7500    1.0000    1.7500    1    10.0000    2
    2    9    3    0.0000    1.7500    16127.5033    -0.0058    0.0058    1.0000    1.7500    1.0000    1.7500    1    10.0000    2
];

%% short_pipe data
%
mgc.short_pipe = [
];

%% resistor data
%
mgc.resistor = [
];

%% regulator data
%
mgc.regulator = [
];

%% valve data
% id    fr_junction    to_junction    status
mgc.valve = [
    1    3    2    1
];

%% receipt data
% id    junction_id    injection_min    injection_max    injection_nominal    is_dispatchable    status
mgc.receipt = [
    1    10    0.0000    0.0027    0.0027    1    1
    2    11    0.0000    0.0031    0.0031    1    1
];

%% delivery data
% id    junction_id    withdrawal_min    withdrawal_max    withdrawal_nominal    is_dispatchable    status
mgc.delivery = [
    1    8    0.0000    0.0016    0.0016    1    1
    2    4    0.0000    0.0023    0.0023    1    1
    3    1    0.0000    0.0019    0.0019    1    1
];

%% ne_pipe data
% id	fr_junction	to_junction	diameter	length	friction_factor	p_min	p_max	status	construction_cost
mgc.ne_pipe = [
    4    6    1    0.5000    11.0000    0.0026    1.0000    1.7500    1    1.0e7
];

%% price_zone data
%column_names% id  cost_q_1  cost_q_2  cost_q_3  cost_p_1  cost_p_2  cost_p_3  min_cost  constant_p  comment
mgc.price_zone = [
    1    0.0   0.0    0.0    8.85e-24    -1.35e-10    0.0       0.0    175.0 'Zone 1'
    2    0.0   0.0    0.0    0.0          1.05e-12    794.37    0.0    600.0 'Zone 2'
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
];

end
