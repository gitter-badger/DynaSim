function data=ProbeFI(model,varargin)
%% data=ProbeFI(model,varargin)
% purpose: run experiment delivering varying levels of tonic input to each 
% population across multiple simulations.
% inputs:
%   model - DynaSim model structure
%   options:
%     target - ...
%     amplitudes - ...
%     (any options for SimulateModel)
%     (any options for CalcFR)
% outputs:
%   array of DynaSim data structures for simulations varying inputs
% 
% see also: SimulateModel, CalcFR

options=CheckOptions(varargin,{...
  'target','ODE1',[],...
  'amplitudes',-10:5:10,[],...
  },false);

model=CheckModel(model);

npops=length(model.specification.populations);
modifications=cell(npops,3);
vary=cell(npops,3);
for i=1:npops
  name=model.specification.populations(i).name;
  % prepare list of modifications to add tonic drive to all populations in model
  modifications(i,:)={name,'equations',['cat(' options.target ',+TONIC)']};
  % prepare specification to vary tonic drive across simulations
  vary(i,:)={name,'TONIC',options.amplitudes};
end

% apply modifications
model=ApplyModifications(model,modifications);

% run simulations varying tonic drives
data=SimulateModel(model,'vary',vary,varargin{:});

% prepare CalcFR options:
if ~any(cellfun(@(x)isequal(x,'variable'),varargin))
  % default to extract spike events from the first state variable
  var=regexp(model.state_variables{1},'_(\w+)$','tokens','once');
  if ~isempty(var)
    varargin{end+1}='variable';
    varargin{end+1}=['*_' var{1}];
  end
end
% calculate resulting firing rates for each population
data=CalcFR(data,varargin{:});
