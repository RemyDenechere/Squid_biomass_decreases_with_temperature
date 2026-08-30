% AXES_FORMATING:
% Define a series of basic axes default value.  
%
% Usage: axes_formating(uiObject, option)
%
% uiObject: can be one of three type
%   - groot: Root — values apply to objects created in current MATLAB® session
%   - gcf:  Figure — use for default values applied to children of the figure defining 
%     the defaults.
%   - gca: Axes — use for default values applied only to children of the axes defining 
%     the defaults and only when using low-level functions (light, line, patch,
%     rectangle, surface, text, and the low-level form of image)."
%
% Define a default property value using a character vector with these three parts:
%       'default' ObjectType PropertyName
%
% see also: Graphics and set

%!!! This does not applie to gscatter functions. 
function axes_formating(uiObject, option)
% function setup: --------------------------------------------------------
arguments
    uiObject                                                       = gcf()
    option.LineLineWidth                                    double = 1.5
    option.LineMarkerSize                                   double = 15
    option.LineMarker                                         char = 'O'
    option.LineFontSize                                     double = 11
    option.AxesTitleHorizontalAlignment                       char = 'center'
    option.AxesXScale                                         char = 'linear'
    option.AxesYScale                                         char = 'linear'
    option.AxesBox                                            char = 'on'
    option.AxesBackgroundColor                              double = [1,1,1]
    option.defaultAxesColorOrder                            double =    [0,    0.4470,    0.7410;
                                                                    0.8500,    0.3250,    0.0980;
                                                                    0.9290,    0.6940,    0.1250;
                                                                    0.4940,    0.1840,    0.5560;
                                                                    0.4660,    0.6740,    0.1880;
                                                                    0.3010,    0.7450,    0.9330;
                                                                    0.6350,    0.0780,    0.1840]
end 
  

% Define the level at which the function occurs: --------------------------

set(uiObject,...                           % Define default level at wich the formating is made 
    'DefaultLineLineWidth',  option.LineLineWidth, ...      % Line properties 
    'DefaultLineMarkerSize', option.LineMarkerSize, ...
    'DefaultLineMarker',     option.LineMarker, ...
    'DefaultAxesFontSize', option.LineFontSize,...     % Axes properties 
    'DefaultAxesTitleHorizontalAlignment', option.AxesTitleHorizontalAlignment, ...
    'DefaultAxesXScale', option.AxesXScale,...
    'DefaultAxesYScale', option.AxesYScale, ...
    'DefaultAxesBox', option.AxesBox, ...
    'DefaultAxesColor', option.AxesBackgroundColor, ...
    'DefaultAxesColorOrder', option.defaultAxesColorOrder)%,...
    %'DefaultFigureInvertHardcopy', 'off'
end


%     'DefaultLineMarkerFaceColor', option.LineMarkerFaceColor, ...
% , ...         % Tiledlayout formating
%     'DefaultLineTiledChartLayoutTileSpacing', 'compact', ...
%     'DefaultLineTiledChartLayoutPadding', 'compact')
