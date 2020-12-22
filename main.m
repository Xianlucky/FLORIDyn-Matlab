%======= Main script to initialize and start a FLORIDyn simulation =======%
% This script may serve as an example on how to prepare and start a       %
% FLORIdyn simulation. This script contains a brief explanation of the    %
% settings. More information about the variables and settings is given in %
% used functions as well as default values.                               %
% ======================================================================= %
% For questions and remarks please contact marcus.becker@tudelft.nl       %
% This code is part of the master thesis of Marcus Becker. The thesis is  %
% avaiable upon request, the results will be published as a paper as soon %
% as possible.                                                            %
% ======================================================================= %
main_addPaths;

%% Set controller type
% Setting for the contoller
% Control.Type:
%   'SOWFA_greedy_yaw'  -> Uses SOWFA yaw angles and a greedy controller
%                           for C_T and C_P based on lookup tables and the 
%                           wind speed (needs additional files)
%   'SOWFA_bpa_tsr_yaw' -> Uses SOWFA yaw angles, blade-pitch-angles and
%                           tip-speed-ratio (needs additional files)
%   'FLORIDyn_greedy'   -> A greedy controller based on lookup tables and 
%                           the wind speed (no additional files)
% 
% Control.init:
%   Set to true if you are starting a new simulation, if you are copying
%   the states from a previous simulation, set to false.

Control.Type = 'FLORIDyn_greedy';
Control.init = true;

%% Load Layout
%   Load the turbine configuration (position, diameter, hub height,...) the
%   power constants (Efficiency, p_p), data to connect wind speed and
%   power / thrust coefficient and the configuration of the OP-chains:
%   relative position, weights, lengths etc.
%
%   Currently implemented Layouts
%       'oneDTU10MW'    -> one turbine
%       'twoDTU10MW'    -> two turbines at 900m distance
%       'nineDTU10MW'   -> nine turbines in a 3x3 grid, 900m dist.
%       'threeDTU10MW'  -> three turbines in 1x3 grid, 5D distance
%       'fourDTU10MW'   -> 2x2 grid 
%  
%   Chain length & the number of chains can be set as extra vars, see 
%   comments in the function for additional info.
[T,fieldLims,Pow,VCpCt,chain] = loadLayout('twoDTU10MW');

%% Load the environment
%   U provides info about the wind: Speed(s), direction(s), changes.
%   I does the same, but for the ambient turbulence, UF hosts constant
%   used for the wind field interpolation, the air density, atmospheric
%   stability etc. The Sim struct holds info about the simulation: Duration
%   time step, various settings. See comments in the function for 
%   additional info.
% 
%   Currently implemented scenarios:
%       'const'                     -> Constant wind speed, direction and 
%                                       amb. turbulence
%       '+60DegChange'              -> 60 degree wind angle change after
%                                       300s (all places at the same time)  
%       'Propagating40DegChange'    -> Propagating 40 degree wind angle
%                                       change starting after 300s
%
%   Numerous settings can be set via additional arguments, see the comments
%   for more info.
[U, I, UF, Sim] = loadWindField('const',... 
    'windAngle',0,...
    'SimDuration',1000,...
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.1,...
    'windSpeed',8,...
    'ambTurbulence',0.06);

%% Visulization
% Set to true or false
%   .online:      Scattered OPs in the wake with quiver wind field plot
%   .Snapshots:   Saves the Scattered OP plots, requires online to be true
%   .FlowField:   Plots the flow field at the end of the simulation
%   .PowerOutput: Plots the generated power at the end of the simulation
%   .Console:     Online simulation progress with duration estimation
%                 (very lightweight, does not require online to be true)
Vis.online      = true;
Vis.Snapshots   = false;
Vis.FlowField   = true;
Vis.PowerOutput = false;
Vis.Console     = true;

%% Create starting OPs and build opList
%   Creates the observation point struct (OP) and extends the chain struct.
%   Here, the distribution of the OPs in the wake is set. Currently the
%   avaiable distributions are:
%   'sunflower'         : Recommended distibution with equal spread of the 
%                           OPs across the rotor plane.
%   '2D_horizontal'     : OPs in two horizontal planes, silightly above and
%                           below hub height
%   '2D_vertical'       : OPs in two vertical planes, right and left of the
%                           narcelle.

[OP, chain] = assembleOPList(chain,T,'sunflower');

%% Running FLORIDyn
[powerHist,OP,T,chain]=...
    FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);

%% ===================================================================== %%
% = Reviewed: 2020.12.22 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %