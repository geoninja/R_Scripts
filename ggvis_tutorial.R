#ggvis tutorial scribbles

library(datasets)
#library(help = "datasets")
#getwd()

mtcars %>% ggvis(~wt, ~mpg, fill := "blue") %>% layer_points() 
#same, without using pipe operator:
layer_points(ggvis(mtcars, ~wt, ~mpg, fill:= "blue"))

#using two layers (points and smooth lines)
mtcars %>% ggvis(~wt, ~mpg, fill := "blue") %>% layer_points() %>% layer_smooths

#practice (note auto legend will overlap)
pressure %>% ggvis(~temperature, ~pressure, fill = ~temperature, size = ~pressure) %>% 
    layer_points()

faithful %>% ggvis(~waiting, ~eruptions) %>% layer_points()

#using 4 variables in graph: fill mapped to species, and size mapped to petal width
#test the following replacements to visualize changes from mapping(=) to setting(:=)
# fill = "red" (data space), fill := "red", size := 100 (both visual space)
iris %>% ggvis(x = ~Sepal.Width, y = ~Sepal.Length, fill = ~Species, size = ~Petal.Width) %>% 
    layer_points()


# Other ways to plot the faithful data

#create object black with name of colors (HTML/CSS)
pressure$black <- c("black", "grey80", "grey50", 
                    "navyblue", "blue", "springgreen4", 
                    "green4", "green", "yellowgreen", 
                    "yellow", "orange", "darkorange", 
                    "orangered", "red", "magenta", "violet", 
                    "purple", "purple4", "slateblue")

pressure %>% 
    ggvis(~temperature, ~pressure, 
          fill := ~black) %>% 
    layer_points()

#Plot 1
faithful %>% ggvis(~waiting, ~eruptions, size = ~eruptions, opacity := 0.5, fill := "blue", 
                   stroke := "black") %>% layer_points()

# Plot 2
faithful %>% ggvis(~waiting, ~eruptions, fillOpacity = ~eruptions, size := 100, fill := "red", 
                   stroke := "blue", shape := "cross") %>% layer_points()


#adding properties to the line marker
pressure %>% ggvis(~temperature, ~pressure) %>% 
             layer_lines(stroke := "red", strokeWidth := 2, strokeDash := 6)

#creating a linear fit model
## compute_smooth() produces an output with the fitted values of y
## arguments: R formula y ~ x, R model function "lm" (default is loess)
faithful %>% compute_model_prediction(eruptions ~ waiting, model = "lm")
mtcars %>% compute_smooth(mpg ~ wt)

# Use 'ggvis()' and 'layer_lines()' to plot the results of compute smooth
mtcars %>% compute_smooth(mpg ~ wt) %>% ggvis(~resp_, ~pred_) %>% layer_lines()

# Recreate the graph you coded above with 'ggvis()' and 'layer_smooths()' 
mtcars %>% ggvis(~wt, ~mpg) %>% layer_smooths()

# Extend the code for the second plot and add 'layer_points()' to the graph
mtcars %>% ggvis(~wt, ~mpg) %>% layer_smooths() %>% layer_points()

#plotting histograms
faithful %>% ggvis(~waiting) %>% layer_histograms()
faithful %>% ggvis(~waiting) %>% layer_histograms(width = 5)

#same as previous
faithful %>% compute_bin(~waiting, width = 5) %>% 
    ggvis(x = ~xmin_, x2 = ~xmax_, y = 0, y2 = ~count_) %>% 
    layer_rects()

#making density plots
faithful %>% compute_density(~waiting) %>% ggvis(~pred_, ~resp_) %>% layer_lines()
#same as above
faithful %>% ggvis(~waiting) %>% layer_densities(fill := "green")

#using dplyr group_by()
mtcars %>% group_by(cyl) %>% ggvis(~mpg, fill = ~factor(cyl)) %>% layer_densities()
#grouping according to more than one variable
mtcars %>% group_by(cyl, am) %>% ggvis(~mpg, fill = ~factor(cyl)) %>% layer_densities()
mtcars %>% group_by(cyl, am) %>% 
           ggvis(~mpg, fill = ~interaction(cyl, am)) %>% 
           layer_densities()

# Creating interactive plots
library("shiny")

# Run this code and inspect the output.
faithful %>% 
    ggvis(~waiting, ~eruptions, fillOpacity := 0.5, 
          shape := input_select(label = "Choose shape:", 
                                choices = c("circle", "square", "cross", "diamond", 
                                            "triangle-up", "triangle-down"))) %>% 
    layer_points()

# added option to select fill color 
faithful %>% 
    ggvis(~waiting, ~eruptions, fillOpacity := 0.5, 
          shape := input_select(label = "Choose shape:", 
                                choices = c("circle", "square", "cross", "diamond", 
                                            "triangle-up", "triangle-down")), 
          fill := input_select(label = "Choose color:", 
                               choices = c("black", "red", "blue", "green"))) %>% 
              layer_points()
          
# another example with radio buttons
mtcars %>% 
    ggvis(~mpg, ~wt, 
          fill := input_radiobuttons(label = "Choose color:", 
                                     choices = c("black", "red", "blue", "green"))) %>% 
    layer_points()

# using input text
mtcars %>% 
    ggvis(~mpg, ~wt, 
          fill := input_text("black", label = "Choose color:")) %>% 
    layer_points()

# mapping fill to a selected data variable as input (fill will change)
mtcars %>% 
    ggvis(~mpg, ~wt,
          fill = input_select(label = "Choose fill variable:", 
                              choices = names(mtcars), map = as.name)) %>% 
    layer_points()

# Map the bindwidth to a numeric field ("Choose a binwidth:") AWESOME!
mtcars %>% 
    ggvis(~mpg) %>% 
    layer_histograms(width = input_numeric(value = 1, label = "Choose a binwidth:"))

# Map the binwidth to a slider bar ("Choose a binwidth:") with the correct specifications
mtcars %>% 
    ggvis(~mpg) %>% 
    layer_histograms(width = input_slider(min = 1, max = 20, label = "Choose a binwidth:"))


mtcars %>% ggvis(~wt, ~mpg) %>% layer_points() %>%
    layer_model_predictions(model = "lm", domain = c(0, 8))


# Multiple layers
pressure %>% ggvis(~temperature, ~pressure) %>%
    layer_lines(stroke := "black", opacity := 0.5) %>% layer_points() %>% 
    layer_model_predictions(model = "lm", stroke := "navy") %>%
    layer_smooths(stroke:= "skyblue")

pressure %>% ggvis(~temperature, ~pressure, stroke := "skyblue", 
                    strokeOpacity := 0.5, strokeWidth := 5) %>% layer_lines() %>% 
             layer_points(fill = ~temperature, shape := "triangle-up", size := 70)

# Defining with axes

#setting titles
faithful %>% 
    ggvis(~waiting, ~eruptions) %>% 
    layer_points() %>% 
    add_axis("y", title = "Duration of eruption (m)") %>%
    add_axis("x", title = "Time since previous eruption (m)")

#setting tick marks (subdivide doesn't include the value mark)
faithful %>% 
    ggvis(~waiting, ~eruptions) %>% 
    layer_points() %>% 
    add_axis("y", title = "Duration of eruption (m)", 
             values = c(2, 3, 4, 5), subdivide = 9) %>% 
    add_axis("x", title = "Time since previous eruption (m)",
             values = c(50, 60, 70, 80, 90), subdivide = 9)

#changing axes' locations
faithful %>% 
    ggvis(~waiting, ~eruptions) %>% 
    layer_points() %>%
    add_axis("x", orient = "top") %>%
    add_axis("y", orient = "right")

# Working with the legend
faithful %>% 
    ggvis(~waiting, ~eruptions, opacity := 0.6, 
          fill = ~factor(round(eruptions))) %>% 
    layer_points() %>%
    add_legend("fill", title = "duration (m)", orient = "left")

# Combining the properties' legends.
faithful %>% 
    ggvis(~waiting, ~eruptions, opacity := 0.6, 
          fill = ~factor(round(eruptions)), shape = ~factor(round(eruptions)), 
          size = ~round(eruptions))  %>%
    layer_points() %>%
    add_legend(c("fill", "shape", "size"), title = "duration (m)", values = c(2, 3, 4, 5))


# Using scale to vary the visual range of the properties (according to data type)

# Stroke color range from "darkred" to "orange".
mtcars %>% 
    ggvis(~wt, ~mpg, fill = ~disp, stroke = ~disp, strokeWidth := 2) %>%
    layer_points() %>%
    scale_numeric("fill", range = c("red", "yellow")) %>%
    scale_numeric("stroke", range = c("darkred", "orange"))

# Fill colors range from green to beige.
mtcars %>% ggvis(~wt, ~mpg, fill = ~hp) %>%
    layer_points() %>%
    scale_numeric("fill", range = c("green", "beige"))

# Map `factor(cyl)` to a range of colors: purple, blue, and green. 
mtcars %>% ggvis(~wt, ~mpg, fill = ~factor(cyl)) %>%
    layer_points() %>%
    scale_nominal("fill", range = c("purple", "blue", "green"))

# Scale limits the range of opacity from 0.2 to 1 (w/o scale some points are too clear)
mtcars %>% ggvis(x = ~wt, y = ~mpg, fill = ~factor(cyl), opacity = ~hp) %>%
    layer_points() %>% scale_numeric("opacity", range = c(0.2, 1))

# Scales to expand the x axis to cover data values from 0 to 6, and y axis from 0 to its max.
mtcars %>% ggvis(~wt, ~mpg, fill = ~disp) %>%
    layer_points() %>%
    scale_numeric("y", domain = c(0, NA)) %>%
    scale_numeric("x", domain = c(0, 6))

# Set the fill value to the color variable instead of mapping it: no scaling happens
mtcars$color <- c("red", "teal", "#cccccc", "tan") #creates a column with color names
mtcars %>% ggvis(x = ~wt, y = ~mpg, fill := ~color) %>% layer_points()



