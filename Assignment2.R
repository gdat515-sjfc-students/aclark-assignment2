library(tidyverse)
library(devtools)
library(nflscrapR)
library(teamcolors)

setwd("~/Documents/GitHub/GDAT515/aclark-Assignment2")
kc_color <- teamcolors %>%
  filter(league == "nfl") %>%
  filter(name == "Kansas City Chiefs")

pbp_2019 <- scrape_season_play_by_play(2019, "reg", teams = "KC")

write.csv(pbp_2019, "pbp2019.csv", row.names = FALSE)

plyr_lkup <- read.csv("plyaer_no_pos.csv")

mahomes <- pbp_2019 %>% filter(posteam == "KC" & passer_player_name == "P.Mahomes" & sack == 0) %>% drop_na(receiver_player_name, air_yards)

wr_stats <- mahomes %>% group_by(receiver_player_name, receiver_player_id) %>% summarise(count = n(), air_yards = mean(air_yards)) %>%
  rename(Name = receiver_player_name, Id = receiver_player_id)

wr_location <- mahomes %>%
  group_by(receiver_player_name, receiver_player_id, pass_location) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = pass_location, values_from = count) %>%
  replace(is.na(.), 0)

locale <- data.frame(locale = colnames(wr_location[3:5])[max.col(wr_location[3:5],ties.method="first")])

wr_stats <- bind_cols(wr_stats, locale)

set.seed(223)
wr_stats_left <- wr_stats %>% filter(locale == 'left')
wr_stats_left$locale_num <- runif(nrow(wr_stats_left), min=1, max=5)
wr_stats_middle <- wr_stats %>% filter(locale == 'middle') %>% mutate(locale_num = 0)
wr_stats_right <- wr_stats %>% filter(locale == 'right')
wr_stats_right$locale_num <- runif(nrow(wr_stats_right), min=-5, max=-1)

wr_stats <- bind_rows(wr_stats_left, wr_stats_middle, wr_stats_right)
pat <- mahomes %>%
  select(passer_player_name, passer_player_id) %>%
  distinct() %>%
  mutate(count = 0, air_yards = -0.2, locale = "middle", locale_num = 0) %>%
  rename(Name = passer_player_name, Id = passer_player_id)

wr_stats <- bind_rows(wr_stats, pat)

wr_stats <- merge(wr_stats, plyr_lkup)


ggplot(data = wr_stats, aes(x=air_yards, y =locale_num)) +
  geom_vline(xintercept = 0, linetype = "solid",colour = "black", alpha = .5) +
  geom_vline(xintercept = 1:21, linetype = "solid",colour = "white", alpha = .3) +
  geom_vline(xintercept = 10, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 20, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 10, linetype = "solid",colour = "yellow", alpha = .5) +
  geom_hline(yintercept = .45, linetype = "dashed",colour = "white") +
  geom_hline(yintercept = -.45, linetype = "dashed",colour = "white") +
  geom_text(aes(label=Name),hjust=0.4, vjust=-1.5, angle = 0, fontface = "bold") +
  geom_point(aes(shape = Pos),size = 10, color = unique(kc_color$primary)) +
  scale_shape_manual(values =c(25,19,15,18)) +
  geom_text(aes(label=No),hjust=0.5, vjust=0.5, colour = "black", size = 4, fontface = "bold") +
  theme(panel.background = element_rect(fill = "#7cfc00",
                                        colour = "#7cfc00"),
       panel.grid.major = element_blank(),
       panel.grid.minor = element_blank(),
       axis.title.y =element_blank(),
       axis.text.y=element_blank(),
       axis.ticks.y=element_blank(),
       plot.title = element_text(hjust = 0.5),
       plot.subtitle = element_text(hjust = 0.5)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 3)) +
  xlab("Average Air Yards") +
  ggtitle("Patrick Mahomes 2019 Targets", subtitle = "Average Air Yards From Release Point") +
  labs(shape = "Position") +
  annotate("text", x = -.3, y = -1.5, label = "Release Point", angle = 90) +
  annotate("text", x = 9.7, y = 4.3, label = "First Down", angle = 90)

all_mahomes <- mahomes %>% select(pass_location, air_yards, incomplete_pass)
all_passes_left <- all_mahomes %>% filter(pass_location == 'left')
all_passes_left$pass_location <- runif(nrow(all_passes_left), min=1, max=5)
all_passes_middle <- all_mahomes %>% filter(pass_location == 'middle')
all_passes_middle$pass_location <- runif(nrow(all_passes_middle), min=-.99, max=.99)
all_passes_right <- all_mahomes %>% filter(pass_location == 'right')
all_passes_right$pass_location <- runif(nrow(all_passes_right), min=-5, max=-1)

all_passes <- bind_rows(all_passes_left, all_passes_middle, all_passes_right)
all_passes$incomplete_pass <- as.factor(all_passes$incomplete_pass)

ggplot(data = all_passes, aes(x=air_yards, y =pass_location, shape = incomplete_pass, color = incomplete_pass)) +
  geom_vline(xintercept = -10, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 0, linetype = "solid",colour = "black", alpha = .5) +
  geom_vline(xintercept = -10:52, linetype = "solid",colour = "white", alpha = .3) +
  geom_vline(xintercept = 10, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 20, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 30, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 40, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 50, linetype = "solid",colour = "white") +
  geom_vline(xintercept = 10, linetype = "solid",colour = "yellow", alpha = .5) +
  geom_hline(yintercept = .45, linetype = "dashed",colour = "white") +
  geom_hline(yintercept = -.45, linetype = "dashed",colour = "white") +
  geom_point() +
  scale_shape_manual(values =c(1,4)) +
  scale_color_manual(breaks = c("0","1"),
                     values=c("blue", "red")) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 6), limits = c(-10,52)) +
  theme(panel.background = element_rect(fill = "#7cfc00",
                                        colour = "#7cfc00"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.y =element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  #scale_x_continuous(breaks = scales::pretty_breaks(n = 3)) +
  xlab("Average Air Yards") +
  ggtitle("Patrick Mahomes 2019 Targets", subtitle = "Average Air Yards From Release Point") +
  labs(shape = "Position") 
