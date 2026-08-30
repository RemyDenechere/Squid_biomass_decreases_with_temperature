% Plots a shaded region on a graph between specified lower and upper confidence intervals (L and U).
% l and u must be vectors of the same length.
% Uses the 'fill' function, not 'area'. Therefore multiple shaded plots
% can be overlayed without a problem. Make them transparent for total visibility.
% x data can be specified, otherwise plots against index values.
% colour can be specified (eg 'k'). Defaults to blue.
% Rémy Denéchère 02/29/2024 based on Raymond Reynolds 24/11/06 

% Usage: 
% ciplot(lower,upper)       
% ciplot(lower,upper,x)
% ciplot(lower,upper,x,option)
% ciplot(lower,upper,  option)


function plot_handle = ciplot(lower, upper, x, option)
     arguments 
        lower             double 
        upper             double 
        x                 {mustBeNumeric}                                   = 1:length(Lower)
        option.colour                                                       = 'b'
        option.alpha      double                                            = 0.5
        option.Linestyle  string {mustBeMember(option.Linestyle, ["-", "--",":","-.", "none"])} = "-"
        option.VisLegend  string {mustBeMember(option.VisLegend, ["on", "off"])}                = "off"
     end 


if length(lower)~=length(upper)
    error('lower and upper vectors must be same length')
elseif length(x)~=length(upper)
    error('x and upper vectors must be same length')
end


% convert to row vectors so fliplr can work
if find(size(x)==(max(size(x))))<2
    x=x'; end
if find(size(lower)==(max(size(lower))))<2
    lower=lower'; end
if find(size(upper)==(max(size(upper))))<2
    upper=upper'; end

plot_handle = fill([x fliplr(x)],[upper fliplr(lower)],  option.colour, ...
    'FaceAlpha', option.alpha ,'LineStyle', option.Linestyle, 'EdgeColor', 'none', ...
    'HandleVisibility', option.VisLegend); 
end

