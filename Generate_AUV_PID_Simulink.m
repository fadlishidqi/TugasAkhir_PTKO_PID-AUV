% Auto-generate STABLE Simulink model for AUV Depth Control with PID
clear; clc;
modelName = 'AUV_PID_Model_Stable';

% Delete existing model if exists
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% Create new model
new_system(modelName);
open_system(modelName);

%% Main Model - STABLE Configuration
% Add Step Input
add_block('simulink/Sources/Step', [modelName '/Step'], 'Position', [50 95 80 125]);
set_param([modelName '/Step'], 'Time', '2', 'Before', '0', 'After', '10');

% Add Sum Block
add_block('simulink/Math Operations/Sum', [modelName '/Sum'], ...
    'Inputs', '+-', 'Position', [120 90 140 130]);

% Add PID Controller with STABLE parameters
add_block('simulink/Continuous/PID Controller', [modelName '/PID'], ...
    'Position', [170 85 250 135]);
% STABLE PID Parameters - Much more conservative
set_param([modelName '/PID'], 'P', '0.8', 'I', '0.1', 'D', '0.2', 'N', '10');

%% Create Simplified Inverse Kinematics Subsystem
invKinSubsystem = [modelName '/Inverse_Kinematics'];
add_block('simulink/Ports & Subsystems/Subsystem', invKinSubsystem, ...
    'Position', [280 80 380 140]);

% Build Inverse Kinematics Subsystem
open_system(invKinSubsystem);
delete_block([invKinSubsystem '/In1']);
delete_block([invKinSubsystem '/Out1']);

% Input: Control command
add_block('simulink/Sources/In1', [invKinSubsystem '/Control_Input'], ...
    'Position', [50 90 80 110]);

% Simple unity gain (no amplification to avoid instability)
add_block('simulink/Math Operations/Gain', [invKinSubsystem '/Unity_Gain'], ...
    'Position', [120 85 150 115]);
set_param([invKinSubsystem '/Unity_Gain'], 'Gain', '1');

% Low-pass filter for stability
add_block('simulink/Continuous/Transfer Fcn', [invKinSubsystem '/Stability_Filter'], ...
    'Position', [180 80 260 120]);
set_param([invKinSubsystem '/Stability_Filter'], 'Numerator', '10', 'Denominator', '[1 10]');

% Output
add_block('simulink/Sinks/Out1', [invKinSubsystem '/Force_Output'], ...
    'Position', [290 95 320 115]);

% Connect Inverse Kinematics
add_line(invKinSubsystem, 'Control_Input/1', 'Unity_Gain/1');
add_line(invKinSubsystem, 'Unity_Gain/1', 'Stability_Filter/1');
add_line(invKinSubsystem, 'Stability_Filter/1', 'Force_Output/1');

%% Create Stable Thruster System Subsystem
thrusterSubsystem = [modelName '/Thruster_System'];
add_block('simulink/Ports & Subsystems/Subsystem', thrusterSubsystem, ...
    'Position', [410 80 510 140]);

% Build Thruster System Subsystem
open_system(thrusterSubsystem);
delete_block([thrusterSubsystem '/In1']);
delete_block([thrusterSubsystem '/Out1']);

% Input
add_block('simulink/Sources/In1', [thrusterSubsystem '/Thruster_Input'], ...
    'Position', [50 90 80 110]);

% Conservative thruster dynamics for stability
add_block('simulink/Continuous/Transfer Fcn', [thrusterSubsystem '/Thruster_Dynamics'], ...
    'Position', [120 80 200 120]);
set_param([thrusterSubsystem '/Thruster_Dynamics'], 'Numerator', '5', 'Denominator', '[1 5]');

% Output with unity gain
add_block('simulink/Math Operations/Gain', [thrusterSubsystem '/Output_Gain'], ...
    'Position', [230 85 260 115]);
set_param([thrusterSubsystem '/Output_Gain'], 'Gain', '1');

% Output
add_block('simulink/Sinks/Out1', [thrusterSubsystem '/Thrust_Output'], ...
    'Position', [290 95 320 115]);

% Connect Thruster System
add_line(thrusterSubsystem, 'Thruster_Input/1', 'Thruster_Dynamics/1');
add_line(thrusterSubsystem, 'Thruster_Dynamics/1', 'Output_Gain/1');
add_line(thrusterSubsystem, 'Output_Gain/1', 'Thrust_Output/1');

%% Back to Main Model
open_system(modelName);

% Add Plant with damping for stability
add_block('simulink/Continuous/Transfer Fcn', [modelName '/Plant'], ...
    'Position', [540 85 620 135]);
% Add damping term to prevent oscillation: 1/(s² + 0.5s) instead of 1/s²
set_param([modelName '/Plant'], 'Numerator', '1', 'Denominator', '[1 0.5 0]');

% Add Main Scope
add_block('simulink/Sinks/Scope', [modelName '/Scope'], 'Position', [660 70 710 120]);
set_param([modelName '/Scope'], 'NumInputPorts', '2');

% Add PID Output Scope
add_block('simulink/Sinks/Scope', [modelName '/PID_Output_Scope'], 'Position', [660 140 710 180]);

% Add Thruster Scope
add_block('simulink/Sinks/Scope', [modelName '/Thruster_Scope'], 'Position', [660 190 710 230]);

% Add To Workspace blocks
add_block('simulink/Sinks/To Workspace', [modelName '/Depth_Data'], ...
    'Position', [750 75 800 105]);
set_param([modelName '/Depth_Data'], 'VariableName', 'depth_response', 'SaveFormat', 'Array');

add_block('simulink/Sinks/To Workspace', [modelName '/Reference_Data'], ...
    'Position', [750 115 800 145]);
set_param([modelName '/Reference_Data'], 'VariableName', 'reference_signal', 'SaveFormat', 'Array');

add_block('simulink/Sinks/To Workspace', [modelName '/PID_Data'], ...
    'Position', [750 155 800 185]);
set_param([modelName '/PID_Data'], 'VariableName', 'pid_output', 'SaveFormat', 'Array');

%% Connect All Blocks
% Main signal flow
add_line(modelName, 'Step/1', 'Sum/1', 'autorouting', 'on');
add_line(modelName, 'Sum/1', 'PID/1', 'autorouting', 'on');
add_line(modelName, 'PID/1', 'Inverse_Kinematics/1', 'autorouting', 'on');
add_line(modelName, 'Inverse_Kinematics/1', 'Thruster_System/1', 'autorouting', 'on');
add_line(modelName, 'Thruster_System/1', 'Plant/1', 'autorouting', 'on');

% Feedback loop
add_line(modelName, 'Plant/1', 'Sum/2', 'autorouting', 'on');

% Scope connections
add_line(modelName, 'Step/1', 'Scope/1', 'autorouting', 'on');        % Reference (kuning)
add_line(modelName, 'Plant/1', 'Scope/2', 'autorouting', 'on');       % Response (biru)

% Monitoring
add_line(modelName, 'PID/1', 'PID_Output_Scope/1', 'autorouting', 'on');
add_line(modelName, 'Inverse_Kinematics/1', 'Thruster_Scope/1', 'autorouting', 'on');

% Data logging
add_line(modelName, 'Plant/1', 'Depth_Data/1', 'autorouting', 'on');
add_line(modelName, 'Step/1', 'Reference_Data/1', 'autorouting', 'on');
add_line(modelName, 'PID/1', 'PID_Data/1', 'autorouting', 'on');

%% Configure for STABLE simulation
% Conservative simulation parameters
set_param(modelName, 'StopTime', '30');
set_param(modelName, 'Solver', 'ode45');           
set_param(modelName, 'MaxStep', '0.01');           
set_param(modelName, 'RelTol', '1e-4');            
set_param(modelName, 'AbsTol', '1e-6');            

% Configure scopes
set_param([modelName '/Scope'], 'YMin', '-2', 'YMax', '15');
set_param([modelName '/Scope'], 'TimeRange', '30');

set_param([modelName '/PID_Output_Scope'], 'YMin', '-10', 'YMax', '20');
set_param([modelName '/PID_Output_Scope'], 'TimeRange', '30');

%% Save and run
save_system(modelName);

% Run simulation automatically
fprintf('🚀 Running STABLE simulation...\n');
sim(modelName);
fprintf('✅ Simulation complete! Check scopes for stable response.\n');