## ---- message = FALSE, warning = FALSE----------------------------------------
# Load packages
  library(lpirfs)
  library(dplyr)
  library(gridExtra)
  library(ggpubr)
  library(readxl)
  library(vars)
  library(ggplot2)
  library(zoo)

## ---- fig.height = 6, fig.width = 6.5, fig.align = "center", message = FALSE, warning = FALSE----
#####################################################################################################
#                            ---   Code for Figure 1  ---                                  
#####################################################################################################

# Load data from lpirfs package
 endog_data <- interest_rules_var_data

# Estimate linear model with lpirfs function
 results_lin <- lp_lin(endog_data,
                       lags_endog_lin = 4,
                       trend          = 0,
                       shock_type     = 0,
                       confint        = 1.96,
                       hor            = 12)

 # Show summary. Equals table 3 in the paper
   summary(results_lin)[[1]][1]

# Figure 1 in paper
 plot(results_lin)


## ---- fig.height = 6, fig.width = 5, fig.align = "center", message = FALSE----
#####################################################################################################
#                          ---  Code for Figure 2 ---
#####################################################################################################

# Choose data for switching variable (here federal funds rate)
  switching_data <-  if_else(dplyr::lag(endog_data$Infl, 3) > 4.75, 1, 0)


# Estimate model and save results
 results_nl    <- lp_nl(endog_data,
                        lags_endog_lin  = 4,
                        lags_endog_nl   = 4,
                        trend           = 0,
                        shock_type      = 0,
                        confint         = 1.96,
                        hor             = 12,
                        switching       = switching_data,
                        lag_switching   = FALSE,
                        use_logistic    = FALSE)


# Use plot functions
 nl_plots <- plot_nl(results_nl)

# Combine plots by using 'ggpubr' and 'gridExtra'
 single_plots      <- nl_plots$gg_s1[c(3, 6, 9)]
 single_plots[4:6] <- nl_plots$gg_s2[c(3, 6, 9)]

 all_plots <- sapply(single_plots, ggplotGrob)
 
# Show all plots
 nl_all_plots <- marrangeGrob(all_plots, nrow = 3, ncol = 2, top = NULL)
 nl_all_plots


## ---- fig.height = 4., fig.width = 6.5, fig.align = "center", message = FALSE, warning = FALSE----
#####################################################################################################
#                           ---  Code for Figure 3 ---
#####################################################################################################

# Load data
 ag_data       <- ag_data
 sample_start  <- 7
 sample_end    <- dim(ag_data)[1]

# Endogenous data
 endog_data    <- ag_data[sample_start:sample_end,3:5]

# Variable to shock with. Here government spending due to
# Blanchard and Perotti (2002) framework
 shock         <- ag_data[sample_start:sample_end, 3]

# Estimate linear model
 results_lin_iv <- lp_lin_iv(endog_data,
                             lags_endog_lin = 4,
                             shock          = shock,
                             trend          = 0,
                             confint        = 1.96,
                             hor            = 20)


# Make and save plots
 iv_lin_plots    <- plot_lin(results_lin_iv)

# This example replicates results from the Supplementary Appendix
# by Ramey and Zubairy (2018) (RZ-18).

# Load and prepare data
 ag_data           <- ag_data
 endog_data        <- ag_data[sample_start:sample_end, 3:5]

# The nonlinear shock is estimated by RZ-18.
 shock             <- ag_data[sample_start:sample_end, 7]

# Include four lags of the 7-quarter moving average growth rate of GDP
# as exogenous variables (see RZ-18)
 exog_data         <- ag_data[sample_start:sample_end, 6]

# Use the 7-quarter moving average growth rate of GDP as switching variable
# and adjust it to have suffiently long recession periods.
 switching_variable <- ag_data$GDP_MA[sample_start:sample_end] - 0.8

# Estimate local projections
 results_nl_iv <- lp_nl_iv(endog_data,
                           lags_endog_nl     = 3,
                           shock             = shock,
                           exog_data         = exog_data,
                           lags_exog         = 4,
                           trend             = 0,
                           confint           = 1.96,
                           hor               = 20,
                           use_hp            = FALSE,
                           switching         = switching_variable,
                           gamma             = 3)

# Make and save plots
 plots_nl_iv <- plot_nl(results_nl_iv)

# Make to list to save all plots
 combine_plots <- list()

# Save linear plots in list
 combine_plots[[1]] <- iv_lin_plots[[1]]
 combine_plots[[2]] <- iv_lin_plots[[3]]

# Save nonlinear plots for expansion period
 combine_plots[[3]] <- plots_nl_iv$gg_s1[[1]]
 combine_plots[[4]] <- plots_nl_iv$gg_s1[[3]]

# Save nonlinear plots for recession period
 combine_plots[[5]] <- plots_nl_iv$gg_s2[[1]]
 combine_plots[[6]] <- plots_nl_iv$gg_s2[[3]]

 lin_plots_all     <- sapply(combine_plots, ggplotGrob)
 combine_plots_all <- marrangeGrob(lin_plots_all, nrow = 2, ncol = 3, top = NULL)


# Show all plots
  combine_plots_all

## ---- fig.height = 2.5, fig.width = 3, fig.align = "center",  message = FALSE, warning = FALSE----
#####################################################################################################
#                               ---  Code for Figure 4 ---
#####################################################################################################

# Go to the website of the 'The MacroFinance and MacroHistory Lab'
# Download the Excel-Sheet of the 'Jordà-Schularick-Taylor Macrohistory Database':
  # URL: https://www.macrohistory.net/database/
  # Then uncomment and run the code below...


# # Load data set
#   jst_data <- read_excel("JSTdatasetR5.xlsx", sheet = "Data")
# 
# 
# # Swap the first two columns
#   jst_data <- jst_data                    %>%
#               dplyr::filter(year <= 2013) %>%
#               dplyr::select(country, year, everything())
# 
# # Prepare variables
#   data_set <- jst_data %>%
#              mutate(stir    = stir)                         %>%
#              mutate(mortgdp = 100*(tmort/gdp))              %>%
#              mutate(hpreal  = hpnom/cpi)                    %>%
#              group_by(country)                              %>%
#              mutate(hpreal  = hpreal/hpreal[year==1990][1]) %>%
#              mutate(lhpreal = log(hpreal))                  %>%
# 
#              mutate(lhpy    = lhpreal - log(rgdppc))        %>%
#              mutate(lhpy    = lhpy - lhpy[year == 1990][1]) %>%
#              mutate(lhpreal = 100*lhpreal)                  %>%
#              mutate(lhpy    = 100*lhpy)                     %>%
#              ungroup()                                      %>%
# 
#              mutate(lrgdp   = 100*log(rgdppc))              %>%
#              mutate(lcpi    = 100*log(cpi))                 %>%
#              mutate(lriy    = 100*log(iy*rgdppc))           %>%
#              mutate(cay     = 100*(ca/gdp))                 %>%
#              mutate(tnmort  = tloans - tmort)               %>%
#              mutate(nmortgdp = 100*(tnmort/gdp))            %>%
#              dplyr::select(country, year, mortgdp, stir, ltrate,
#                                                     lhpy, lrgdp, lcpi, lriy, cay, nmortgdp)
# 
# 
# # Exclude observations from WWI and WWII
#   data_sample <- seq(1870, 2016)[which(!(seq(1870, 2016) %in%
#                                             c(seq(1914, 1918),
#                                             seq(1939, 1947))))]
# 
# # Estimate linear panel model
#   results_panel <- lp_lin_panel(data_set  = data_set,  data_sample  = data_sample,
#                                 endog_data        = "mortgdp", cumul_mult   = TRUE,
#                                 shock             = "stir",    diff_shock   = TRUE,
#                                 panel_model       = "within",  panel_effect = "individual",
#                                 robust_cov        = "vcovSCC", c_exog_data  = "cay",
#                                 c_fd_exog_data    = colnames(data_set)[c(seq(4,9),11)],
#                                 l_fd_exog_data    = colnames(data_set)[c(seq(3,9),11)],
#                                 lags_fd_exog_data = 2,      confint      = 1.67,
#                                 hor               = 10)
# 
# 
# # Plot irfs
#   plot(results_panel)

## ---- fig.height = 2.5, fig.width = 5, fig.align = "center",  message = FALSE, warning = FALSE----
#####################################################################################################
#                           ---  Code for Figure 5 ---
#####################################################################################################

# # Estimate panel model
#  results_panel <- lp_nl_panel(data_set          = data_set,
#                               data_sample       = data_sample,
#                               endog_data        = "mortgdp", cumul_mult     = TRUE,
#                               shock             = "stir",    diff_shock     = TRUE,
#                               panel_model       = "within",  panel_effect   = "individual",
#                               robust_cov        = "vcovSCC", switching      = "lrgdp",
#                               lag_switching     = TRUE,      use_hp         = TRUE,
#                               lambda            = 6.25,      gamma          = 10,
#                               c_exog_data       = "cay",
#                               c_fd_exog_data    = colnames(data_set)[c(seq(4,9),11)],
#                               l_fd_exog_data    = colnames(data_set)[c(seq(3,9),11)],
#                               lags_fd_exog_data = 2,
#                               confint           = 1.67,
#                               hor               = 10)
# 
# 
# 
# # Show non-linear plots
#   plot(results_panel)

## ---- message = FALSE, warning = FALSE----------------------------------------
#####################################################################################################
#                        ---  Code for Figure 6 ---
#####################################################################################################

# Load data from lpirfs package
  endog_data <- interest_rules_var_data

  hor    <- 12
  p_lags <- c(2, 4, 6)

# Results for lpirfs
  results_irf_lpirfs_mean <- array(NA, c(dim(endog_data)[2], hor + 1, 3))
  results_irf_lpirfs_low  <- results_irf_lpirfs_mean
  results_irf_lpirfs_up   <- results_irf_lpirfs_mean

# Results for SVARS
  results_irf_svar_mean   <- array(NA, c(dim(endog_data)[2], hor + 1, 3))
  results_irf_svar_low    <- results_irf_svar_mean
  results_irf_svar_up     <- results_irf_svar_mean


# Estimate irfs for Jordá method
  for(ii in seq_along(p_lags)){

    results_lin <- lp_lin(endog_data,
                        lags_endog_lin = p_lags[ii],
                        trend          = 0,
                        shock_type     = 0,
                        confint        = 1.96,
                        hor            = 12)

    results_irf_lpirfs_mean[, , ii] <- results_lin$irf_lin_mean[, , 1]
    results_irf_lpirfs_low[, , ii]  <- results_lin$irf_lin_low[, , 1]
    results_irf_lpirfs_up[, , ii]   <- results_lin$irf_lin_up[, , 1]

  }





  amat       <- diag(3)
  diag(amat) <- NA

# Estimate results for SVARS
  for(ii in seq_along(p_lags)){


    # Estimate VAR
     var_results <- VAR(endog_data, p = p_lags[ii], type = "const")

     ## Estimation method scoring
     svar_endog_data <- SVAR(x = var_results, estmethod = "scoring", Amat = amat, Bmat = NULL,
                         max.iter = 100, maxls = 1000, conv.crit = 1.0e-8)

    results_irf_svar <- irf(svar_endog_data, impulse = colnames(endog_data), n.ahead = hor)

    results_irf_svar_mean[, , ii] <- t(results_irf_svar$irf[[1]])
    results_irf_svar_low[, , ii]  <- t(results_irf_svar$Lower[[1]])
    results_irf_svar_up[, , ii]   <- t(results_irf_svar$Upper[[1]])

}

shock_names <- names(endog_data)

plot_num     <- 1
gg_lin       <- rep(list(NaN), 3)
x_labs       <- c("p = 2", "p = 4", "p = 6")


gg_lin <- list()
second_color <- "#D55E00"

# Loop to fill to create plots
plot_num  <- 1
for (kk in seq_along(p_lags)){
  for (rr in seq_along(p_lags)){

    legend_title <- paste("p = ", p_lags[kk], sep = "")

    # Extract relevant impulse responses
    tbl_lpirfs_mean <- as.matrix(t(results_irf_lpirfs_mean[, 1:hor , kk]))[, rr]
    tbl_lpirfs_low  <- as.matrix(t(results_irf_lpirfs_low[,  1:hor , kk]))[, rr]
    tbl_lpirfs_up   <- as.matrix(t(results_irf_lpirfs_up[,   1:hor , kk]))[, rr]

    tbl_svar_mean <- as.matrix(t(results_irf_svar_mean[, 1:hor , kk]))[, rr]
    tbl_svar_low  <- as.matrix(t(results_irf_svar_low[,  1:hor , kk]))[, rr]
    tbl_svar_up   <- as.matrix(t(results_irf_svar_up[,   1:hor , kk]))[, rr]


    # Convert to tibble for ggplot
    tbl_lin_lpirfs    <- tibble(x     = seq_along(tbl_lpirfs_mean),  mean = tbl_lpirfs_mean,
                                low   = tbl_lpirfs_low,              up   = tbl_lpirfs_up)


    tbl_lin_svar      <- tibble(x     = seq_along(tbl_svar_mean),    mean = tbl_svar_mean,
                                low   = tbl_svar_low,              up   = tbl_svar_up)


    gg_lin[[plot_num]] <- ggplot()+
                          geom_line(data     = tbl_lin_lpirfs, aes(y = mean, x = x, linetype = "a", color = "a")) +
                          geom_ribbon(data   = tbl_lin_lpirfs, aes(x = x, ymin = low, ymax = up), col = 'grey',
                                      fill   = 'grey', alpha  = 0.3) +

                          geom_line(data       = tbl_lin_svar, aes(y = mean, x = x, linetype = "b", color ="b")) +
                          geom_ribbon(data     = tbl_lin_svar, aes(x = x, ymin = low, ymax = up), col = second_color,
                                      linetype = "dashed",
                                      fill     =  second_color, alpha  = 0.1) +
                          scale_linetype_manual(name = x_labs[kk],
                                                values = c(1, 5),
                                                labels = c("lpirfs", "vars"),
                                                guide   = guide_legend(title.position="top", title.hjust = 0.5)) +
                          scale_color_manual(name = x_labs[kk],
                                             labels = c("lpirfs", "vars"),
                                             values = c("a" = "black", "b" =  second_color),
                                             guide   = guide_legend(title.position="top", title.hjust = 0.5)) +

                          theme_classic() +
                          ggtitle(paste( shock_names[1], 'on', shock_names[rr], sep=" ")) +
                          xlab('') +
                          ylab('') +
                          theme(title           = element_text(size = 7),
                                plot.title      = element_text(hjust = 0.5),
                                axis.text       = element_text(size = 8),
                                legend.position = "bottom",
                                legend.margin   = margin(t =  -.25, r = 0, b = 0, l = .75, unit = "cm"),
                             #   legend.title    = element_text(size = 8),
                                legend.title     = element_blank(),
                                legend.spacing.y = unit(-.25, 'cm'),
                                legend.spacing.x = unit(.05, 'cm'),
                                legend.text     = element_text(size = 7),
                                legend.box      = "horizontal") +
                          scale_y_continuous(expand = c(0, 0))          +
                          scale_x_continuous(expand = c(0, 0),
                                             breaks = seq(0, hor, 2))


    if(rr == 1) gg_lin[[plot_num]] <- gg_lin[[plot_num]] + ylim(-.5, 1.2)
    if(rr == 2) gg_lin[[plot_num]] <- gg_lin[[plot_num]] + ylim(-.2, 1)
    if(rr == 3) gg_lin[[plot_num]] <- gg_lin[[plot_num]] + ylim(-.3, 1.4)

    # Add one to count variable
    plot_num     <- plot_num +  1


  }
}

# Make column plots
a_1 <- ggarrange(gg_lin[[1]], gg_lin[[2]], gg_lin[[3]], ncol = 1, nrow = 3, common.legend = TRUE, legend = "bottom")
a_1 <- annotate_figure(a_1, bottom = text_grob(paste("a.)", "p =", p_lags[1], sep = " "), size = 7, hjust = -.1, vjust = 0.5))


a_2 <- ggarrange(gg_lin[[4]], gg_lin[[5]], gg_lin[[6]], ncol = 1, nrow = 3, common.legend = TRUE, legend = "bottom")
a_2 <- annotate_figure(a_2, bottom = text_grob(paste("b.)", "p = ", p_lags[2], sep = " "), size = 7, hjust = -.1, vjust = 0.5))

a_3 <- ggarrange(gg_lin[[7]], gg_lin[[8]], gg_lin[[9]], ncol = 1, nrow = 3, common.legend = TRUE, legend = "bottom")
a_3 <- annotate_figure(a_3, bottom = text_grob(paste("c.)", "p = ", p_lags[3], sep = " "), size = 7, hjust = -.1, vjust = 0.5))

## ---- fig.height = 6, fig.width = 6.5, fig.align = "center", message = FALSE, warning = FALSE----
# Combine columns
combine_plot <- ggarrange(a_1, a_2, a_3, ncol = 3)
combine_plot

## ---- fig.height = 6, fig.width = 6.5, fig.align = "center", message = FALSE, warning = FALSE----
#####################################################################################################
#                         ---  Code for Figure 7 ---
#####################################################################################################

# Recession dates
  start_rec <- c("1957 Q3", "1960 Q2", "1970 Q1", "1973 Q4", "1980 Q1", "1981 Q3", "1990 Q3", "2001 Q2")
  end_rec   <- c("1958 Q2", "1961 Q1", "1970 Q4", "1975 Q1", "1980 Q3", "1982 Q4", "1991 Q1", "2001 Q4")

# Quarterly fequence for Jordá data
  dates    <- as.yearqtr(seq(as.Date("1955/12/1"), as.Date("2003/1/1"), by = "quarter"))

  nber_rec_se <- tibble(start = as.yearqtr(start_rec), end = as.yearqtr(end_rec)) %>%
                 filter(start %in% dates)                                             %>%
                 mutate(start = as.Date(start))                                       %>%
                 mutate(end   = as.Date(end))

# Convert back with as.Date for ggplot
  dates    <- as.Date(dates)


# Load data from lpirfs package
  endog_data         <- interest_rules_var_data
  switching_variable <-  interest_rules_var_data$GDP_gap
  
  hor        <- 12
  shock_pos  <- 3

# Results for lpirfs
  results_s1_mean        <- matrix(NA, 3, hor + 1)
  results_s1_low         <- results_s1_mean
  results_s1_up          <- results_s1_mean
  
  results_s2_mean        <- matrix(NA, 3, hor + 1)
  results_s2_low         <- results_s2_mean
  results_s2_up          <- results_s2_mean
  
  fz_mat                 <- matrix(NA, 3, dim(endog_data)[1] - 4)

# Choose values for lambda and gamma
  gamma_vals  <- c(1, 5, 10)
#lambda_vals <- c(6.25, 1600, 129,600)

for(ii in seq_along(gamma_vals)){

# Estimate linear model with lpirfs function
  results_nl <- lp_nl(endog_data,
                        lags_endog_lin  = 4,
                        lags_endog_nl   = 4,
                        trend          = 0,
                        shock_type     = 0,
                        switching      = switching_variable,
                        use_hp         = TRUE,
                        lambda         = 1600,
                        gamma          = gamma_vals[ii],
                        confint        = 1.96,
                        hor            = 12,
                        num_cores      = 1)
  
  results_s1_mean[ii, ]        <- results_nl$irf_s1_mean[1, , 3]
  results_s1_low[ii, ]         <- results_nl$irf_s1_low[1, , 3]
  results_s1_up[ii, ]          <- results_nl$irf_s1_up[1, , 3]
  
  results_s2_mean[ii, ]        <- results_nl$irf_s2_mean[1, , 3]
  results_s2_low[ii, ]         <- results_nl$irf_s2_low[1, , 3]
  results_s2_up[ii, ]          <- results_nl$irf_s2_up[1, , 3]
  
  fz_mat[ii, ]                 <- results_nl$fz
  
  }


# Make date sequence and store data in a data.frame for ggplot.
 dates   <- seq(as.Date("1955/12/1"), as.Date("2003/1/1"), by = "quarter")

 col_names <- names(endog_data)

# Colors to use
  col_regime_1 <- "#21618C"
  col_regime_2 <- "#D68910"


irf_s1_plots <- list()
irf_s2_plots <- list()
fz_plots     <- list()

# Loop to fill to create plots
plot_num  <- 1
for (kk in 1:3){


    # Convert matrices to tibble for ggplot
    tbl_s1    <- tibble(x     = 1:dim(results_s1_mean)[2],  mean = results_s1_mean[kk, ],
                                low   = results_s1_low[kk, ],              up   =  results_s1_up[kk, ])

    tbl_s2    <- tibble(x     = 1:dim(results_s2_mean)[2],  mean = results_s2_mean[kk, ],
                        low   = results_s2_low[kk, ],     up   = results_s2_up[kk, ])


    tbl_fz    <- tibble(x = dates, fz = fz_mat[kk, ])


    irf_s1_plots[[plot_num]] <- ggplot() +
                                geom_line(data     = tbl_s1, aes(y = mean, x = x), col = col_regime_1) +
                                geom_ribbon(data   = tbl_s1, aes(x = x, ymin = low, ymax = up), col = 'grey',
                                            fill = 'grey', alpha = 0.3) +
                                theme_classic() +
                                ggtitle(paste("Regime 1: ", col_names[3], 'on', col_names[1], sep=" ")) +
                                xlab('') +
                                ylab('') +
                                theme(title      = element_text(size = 8),
                                      plot.title = element_text(hjust = 0.5)) +
                               # scale_y_continuous(expand = c(0, 0))  +
                                ylim(-1.2, 1.2) +
                                scale_x_continuous(expand = c(0, 0),
                                                   breaks = seq(0, hor, 2))  +
                                geom_hline(yintercept = 0, col = "black", size = 0.25, linetype = "dashed")

    irf_s2_plots[[plot_num]] <- ggplot() +
                                geom_line(data     = tbl_s2, aes(y = mean, x = x), col = col_regime_2) +
                                geom_ribbon(data   = tbl_s2, aes(x = x, ymin = low, ymax = up), col = 'grey',
                                            fill = 'grey', alpha = 0.3) +
                                theme_classic() +
                                ggtitle(paste("Regime 2: ", col_names[3], 'on', col_names[1], sep=" ")) +
                                xlab('') +
                                ylab('') +
                                theme(title      = element_text(size = 8),
                                      plot.title = element_text(hjust = 0.5)) +
                               # scale_y_continuous(expand = c(0, 0))  +
                                ylim(-1.3, 1.3) +
                                scale_x_continuous(expand = c(0, 0),
                                                   breaks = seq(0, hor, 2))  +
                                geom_hline(yintercept = 0, col = "black", size = 0.25, linetype = "dashed")

    # Plot transition function
    fz_plots[[plot_num]]     <- ggplot(data = tbl_fz)                      +
                                geom_rect(data = nber_rec_se, aes(xmin = start, xmax = end,
                                        ymin = 0, ymax = Inf, fill = "a"), alpha = 0.9) +
                                geom_line(aes(x = x, y = fz), size = .5) +

                                ggtitle("NBER dates and transition variable") +
                                theme_classic()               +
                                theme(title      = element_text(size = 8),
                                      plot.title = element_text(hjust = 0.5),
                                      legend.position = c(.5, -.5)) +
                                ylab("")                      +
                                xlab("")                  +
                                scale_x_date(date_breaks = "10 year",  date_labels = "%Y",
                                             expand = c(0, 0)) +
                                scale_y_continuous(expand = c(0, 0)) +
                                 scale_fill_manual(name    = "",
                                  values  = c("grey"),
                                  labels = c("NBER Recessions"))



    plot_num  <- plot_num + 1

  }



# Make column plots
  a_1 <- ggarrange(fz_plots[[1]], irf_s1_plots[[1]], irf_s2_plots[[1]], ncol = 1, nrow = 3)
  a_1 <- annotate_figure(a_1, bottom = text_grob(bquote(paste("a) Results for ", ~gamma == .(gamma_vals[1]))), face = "bold", size = 10, hjust = .3, vjust = .5))

  a_2 <- ggarrange(fz_plots[[2]], irf_s1_plots[[2]], irf_s2_plots[[2]], ncol = 1, nrow = 3)
  a_2 <- annotate_figure(a_2, bottom = text_grob(bquote(paste("b) Results for ", ~gamma == .(gamma_vals[2]))), face = "bold", size = 10, hjust = .3, vjust = .5))

  a_3 <- ggarrange(fz_plots[[3]], irf_s1_plots[[3]], irf_s2_plots[[3]], ncol = 1, nrow = 3)
  a_3 <- annotate_figure(a_3, bottom = text_grob(bquote(paste("c) Results for ", ~gamma == .(gamma_vals[3]))), face = "bold", size = 10, hjust = .3, vjust = .5))


# Combine columns
  combine_plot <- ggarrange(a_1, a_2, a_3, ncol = 3)
  combine_plot



## ---- fig.height = 6, fig.width = 6.5, fig.align = "center", message = FALSE, warning = FALSE----
#####################################################################################################
#                            ---  Code for Figure 8 ---
#####################################################################################################


# Recession dates
  start_rec <- c("1957 Q3", "1960 Q2", "1970 Q1", "1973 Q4", "1980 Q1", "1981 Q3", "1990 Q3", "2001 Q2")
  end_rec   <- c("1958 Q2", "1961 Q1", "1970 Q4", "1975 Q1", "1980 Q3", "1982 Q4", "1991 Q1", "2001 Q4")

# Quarterly fequence for Jordá data
  dates    <- as.yearqtr(seq(as.Date("1955/12/1"), as.Date("2003/1/1"), by = "quarter"))

  nber_rec_se <- tibble(start = as.yearqtr(start_rec), end = as.yearqtr(end_rec)) %>%
                 filter(start %in% dates)                                             %>%
                 mutate(start = as.Date(start))                                       %>%
                 mutate(end   = as.Date(end))

# Convert back with as.Date for ggplot
  dates    <- as.Date(dates)

# Convert back with as.Date for ggplot
  dates    <- as.Date(dates)


# Load data from lpirfs package
  endog_data         <- interest_rules_var_data
  switching_variable <-  interest_rules_var_data$GDP_gap

  hor        <- 12
  shock_pos  <- 3

# Results for lpirfs
  results_s1_mean        <- matrix(NA, 3, hor + 1)
  results_s1_low         <- results_s1_mean
  results_s1_up          <- results_s1_mean
  
  results_s2_mean        <- matrix(NA, 3, hor + 1)
  results_s2_low         <- results_s2_mean
  results_s2_up          <- results_s2_mean
  
  fz_mat                 <- matrix(NA, 3, dim(endog_data)[1] - 4)

# Choose values for lambda
  lambda_vals <- c(6.25, 1600, 129600)

for(ii in seq_along(lambda_vals)){

  # Estimate linear model with lpirfs function
  results_nl <- lp_nl(endog_data,
                      lags_endog_lin  = 4,
                      lags_endog_nl   = 4,
                      trend           = 0,
                      shock_type      = 0,
                      switching       = switching_variable,
                      use_hp          = TRUE,
                      lambda          = lambda_vals[ii],
                      gamma           = 5,
                      confint         = 1.96,
                      hor             = 12,
                      num_cores       = 1)

  results_s1_mean[ii, ]        <- results_nl$irf_s1_mean[1, , 3]
  results_s1_low[ii, ]         <- results_nl$irf_s1_low[1, , 3]
  results_s1_up[ii, ]          <- results_nl$irf_s1_up[1, , 3]

  results_s2_mean[ii, ]        <- results_nl$irf_s2_mean[1, , 3]
  results_s2_low[ii, ]         <- results_nl$irf_s2_low[1, , 3]
  results_s2_up[ii, ]          <- results_nl$irf_s2_up[1, , 3]

 # fz_mat[ii, ]                 <- results_nl$fz
  fz_mat[ii, ]                 <- hp_filter(matrix(switching_variable[(4+1):193]), lambda_vals[ii])[[1]]

}


col_names <- names(endog_data)

# Colors to use
  col_regime_1 <- "#21618C"
  col_regime_2 <- "#D68910"
  
  
  irf_s1_plots <- list()
  irf_s2_plots <- list()
  fz_plots     <- list()

# Loop to fill to create plots
  plot_num  <- 1
  for (kk in 1:3){


  # Convert matrices to tibble for ggplot
  tbl_s1    <- tibble(x     = 1:dim(results_s1_mean)[2],  mean = results_s1_mean[kk, ],
                      low   = results_s1_low[kk, ],              up   =  results_s1_up[kk, ])

  tbl_s2    <- tibble(x     = 1:dim(results_s2_mean)[2],  mean = results_s2_mean[kk, ],
                      low   = results_s2_low[kk, ],     up   = results_s2_up[kk, ])


  tbl_fz    <- tibble(x = dates, fz = fz_mat[kk, ])


  irf_s1_plots[[plot_num]] <- ggplot() +
                              geom_line(data     = tbl_s1, aes(y = mean, x = x), col = col_regime_1) +
                              geom_ribbon(data   = tbl_s1, aes(x = x, ymin = low, ymax = up), col = 'grey',
                                          fill = 'grey', alpha = 0.3) +
                              theme_classic() +
                              ggtitle(paste("Regime 2: ", col_names[3], 'on', col_names[1], sep=" ")) +
                              xlab('') +
                              ylab('') +
                              theme(title      = element_text(size = 8),
                                    plot.title = element_text(hjust = 0.5)) +
                            #  scale_y_continuous(expand = c(0, 0))  +
                              ylim(-1.7, 0.7) +
                              scale_x_continuous(expand = c(0, 0),
                                                 breaks = seq(0, hor, 2))  +
                              geom_hline(yintercept = 0, col = "black", size = 0.25, linetype = "dashed")

  irf_s2_plots[[plot_num]] <- ggplot() +
                              geom_line(data     = tbl_s2, aes(y = mean, x = x), col = col_regime_2) +
                              geom_ribbon(data   = tbl_s2, aes(x = x, ymin = low, ymax = up), col = 'grey',
                                          fill = 'grey', alpha = 0.3) +
                              theme_classic() +
                              ggtitle(paste("Regime 2: ", col_names[3], 'on', col_names[1], sep=" ")) +
                              xlab('') +
                              ylab('') +
                              theme(title      = element_text(size = 8),
                                    plot.title = element_text(hjust = 0.5)) +
                            #  scale_y_continuous(expand = c(0, 0))  +
                              ylim(- 1.2, 0.8) +
                              scale_x_continuous(expand = c(0, 0),
                                                 breaks = seq(0, hor, 2))  +
                              geom_hline(yintercept = 0, col = "black", size = 0.25, linetype = "dashed")

  # Plot transition function
  fz_plots[[plot_num]]     <- ggplot(data = tbl_fz)                      +
                              geom_rect(data = nber_rec_se, aes(xmin = start, xmax = end,
                                                                ymin = -Inf, ymax = Inf, fill = "a"), alpha = 0.9) +
                              geom_line(aes(x = x, y = fz), size = .5) +

                              ggtitle("NBER dates and cyclical HP component") +
                              theme_classic()               +
                              theme(title      = element_text(size = 8),
                                    plot.title = element_text(hjust = 0.5),
                                    legend.position = c(.5, -.5)) +
                              ylab("")                      +
                              xlab("")                  +
                              scale_x_date(date_breaks = "10 year",  date_labels = "%Y",
                                           expand = c(0, 0)) +
                              scale_y_continuous(expand = c(0, 0)) +
                              scale_fill_manual(name    = "",
                                                values  = c("grey"),
                                                labels = c("NBER Recessions"))



  plot_num  <- plot_num + 1

}



# Make column plots
  a_1 <- ggarrange(fz_plots[[1]], irf_s1_plots[[1]], irf_s2_plots[[1]], ncol = 1, nrow = 3)
  a_1 <- annotate_figure(a_1, bottom = text_grob(bquote(paste("a) Results for ", ~lambda == .(lambda_vals[1]))), face = "bold", size = 10, hjust = .3, vjust = .5))
  
  a_2 <- ggarrange(fz_plots[[2]], irf_s1_plots[[2]], irf_s2_plots[[2]], ncol = 1, nrow = 3)
  a_2 <- annotate_figure(a_2, bottom = text_grob(bquote(paste("b) Results for ", ~lambda == .(lambda_vals[2]))), face = "bold", size = 10, hjust = .3, vjust = .5))
  
  a_3 <- ggarrange(fz_plots[[3]], irf_s1_plots[[3]], irf_s2_plots[[3]], ncol = 1, nrow = 3)
  a_3 <- annotate_figure(a_3, bottom = text_grob(bquote(paste("c) Results for ", ~lambda == "129 600")), face = "bold", size = 10, hjust = .4, vjust = .5))

  
# Combine columns
  combine_plot <- ggarrange(a_1, a_2, a_3, ncol = 3)
  combine_plot




## ---- fig.height = 6, fig.width = 6.5, fig.align = "center", message = FALSE, warning = FALSE----
#####################################################################################################
#                   Comparing normal and Newey West standard errors
#####################################################################################################

# Load data from lpirfs package
  endog_data <- interest_rules_var_data
  hor        <- 12
  shock_pos  <- 3

  use_nw      <- c(FALSE, TRUE, TRUE)
  nw_prewhite <- c(FALSE, FALSE, TRUE)

# Results for lpirfs
  results_irf_lpirfs_mean <- array(NA, c(dim(endog_data)[2], hor + 1, 3))
  results_irf_lpirfs_low  <- results_irf_lpirfs_mean
  results_irf_lpirfs_up   <- results_irf_lpirfs_mean

# Estimate irfs for Jordá method
for(ii in 1:3){

  results_lin <- lp_lin(endog_data,
                        lags_endog_lin = 4,
                        trend          = 0,
                        shock_type     = 0,
                        confint        = 1.96,
                        use_nw         = use_nw[ii],
                        nw_prewhite    = nw_prewhite[ii],
                        hor            = 12)

  results_irf_lpirfs_mean[, , ii] <- results_lin$irf_lin_mean[, , shock_pos]
  results_irf_lpirfs_low[, , ii]  <- results_lin$irf_lin_low[, , shock_pos]
  results_irf_lpirfs_up[, , ii]   <- results_lin$irf_lin_up[, , shock_pos]

}

shock_names <- colnames(endog_data)


gg_lin <- list()
x_labs <- c("a.) Normal Std. Errors", "b.) Newy West (1987)", "c.) Pre-whitened NW (1987)")


# Loop to fill to create plots
  plot_num  <- 1
  for (kk in 1:3){
    for (rr in 1:3){

      # Extract relevant impulse responses
      tbl_lpirfs_mean <- as.matrix(t(results_irf_lpirfs_mean[, 1:hor , kk]))[, rr]
      tbl_lpirfs_low  <- as.matrix(t(results_irf_lpirfs_low[,  1:hor , kk]))[, rr]
      tbl_lpirfs_up   <- as.matrix(t(results_irf_lpirfs_up[,   1:hor , kk]))[, rr]

      # Convert to tibble for ggplot
      tbl_lin_lpirfs    <- tibble(x     = seq_along(tbl_lpirfs_mean),  mean = tbl_lpirfs_mean,
                                  low   = tbl_lpirfs_low,              up   = tbl_lpirfs_up)



      gg_lin[[plot_num]] <- ggplot()+
                            geom_line(data     = tbl_lin_lpirfs, aes(y = mean, x = x)) + # , linetype = "a", color = "a"
                            geom_ribbon(data   = tbl_lin_lpirfs, aes(x = x, ymin = low, ymax = up), col = 'grey',
                                        fill   = 'grey', alpha  = 0.3) +

                            theme_classic() +
                            ggtitle(paste(shock_names[shock_pos], 'on', shock_names[rr], sep=" ")) +
                            xlab('') +
                            ylab('') +
                            theme(title           = element_text(size = 6),
                                  plot.title      = element_text(hjust = 0.5),
                                  axis.title.x    = element_text(size = 8, face="bold")) +
                            scale_x_continuous(expand = c(0, 0),
                                               breaks = seq(0, hor, 2)) +
                            geom_hline(yintercept = 0, col = "black", size = 0.25, linetype = "dashed")

      if(plot_num   %in% c(1, 4, 7)) gg_lin[[plot_num]] <-   gg_lin[[plot_num]] +   ylim(-1, .2)
      if(plot_num   %in% c(2, 5, 8)) gg_lin[[plot_num]] <-   gg_lin[[plot_num]] +   ylim(- .85, .5)
      if(plot_num   %in% c(3, 6, 9)) gg_lin[[plot_num]] <-   gg_lin[[plot_num]] +   ylim(- .7, 1.2)


      if(!(plot_num %in% c(3, 6, 9))) gg_lin[[plot_num]] <-   gg_lin[[plot_num]] +

        theme(axis.title.x    = element_blank(),
              axis.text.x     = element_blank())

      # Add one to count variable
      plot_num     <- plot_num +  1


    }
  }

# Make column plots
  a_1 <- ggarrange(gg_lin[[1]], gg_lin[[2]], gg_lin[[3]], ncol = 1, nrow = 3, common.legend = TRUE)
  a_1 <- annotate_figure(a_1, bottom = text_grob(x_labs[1], size = 8, hjust = .3, vjust = -1))

  a_2 <- ggarrange(gg_lin[[4]], gg_lin[[5]], gg_lin[[6]], ncol = 1, nrow = 3, common.legend = TRUE)
  a_2 <- annotate_figure(a_2, bottom = text_grob(x_labs[2],  size = 8, hjust = .3, vjust = -1))

  a_3 <- ggarrange(gg_lin[[7]], gg_lin[[8]], gg_lin[[9]], ncol = 1, nrow = 3, common.legend = TRUE)
  a_3 <- annotate_figure(a_3, bottom = text_grob(x_labs[3], size = 8, hjust = .3, vjust = -1))
  
  
# Combine columns
  combine_plot <- ggarrange(a_1, a_2, a_3, ncol = 3)
  combine_plot




