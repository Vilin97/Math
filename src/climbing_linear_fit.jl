
twofeatures(data) = reshape([data..., data.^2...], length(data), 2)
xs = [0,15, 17, 22, 25, 30] 
n = length(xs)
features = twofeatures(xs)
ys = 0:5
using Plots
p_ = scatter(xs,ys, xlabel = "minutes of climbing", ylabel = "number of pinks", color=RGB(1.0, 0.2, 0.6), linewidth = 10, markershape= :star6, markersize = 10, label = "real data");
new_xs = 0:60
# plot!(p_, new_xs, twofeatures(new_xs)*w, color=RGB(1.0, 0.2, 0.6), label = "best fit")
# w = inv(transpose(features)*features) * transpose(features) * ys 
w = inv(transpose(xs)*xs) * transpose(xs) * ys 
plot!(p_, new_xs, new_xs*w, color=RGB(1.0, 0.2, 0.6), label = "best fit")