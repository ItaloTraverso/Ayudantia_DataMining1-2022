library(dplyr)
library(tidyverse)
library(ggplot2)
library(plyr)

beats.rds <- "D:\\Users\\Italo\\Documents\\Italo Felipe\\UAI\\Semestre 1-2022\\Mineria de Datos\\Proyecto\\beats.rds"
data <- readRDS(beats.rds)

playlist <- function(df, artista, cancion) {
  a <- artista
  c <- cancion
  
  df <- df[!duplicated(data[c("artist_name","track_name")]),]
  
  cols <- c("track_name","artist_name","duration_ms","danceability","energy","loudness","valence")
  df <- df %>% select(all_of(cols))
  df <- df %>% mutate(duration_min = duration_ms/60000) #Pasamos a minutos la duración
  df$duration_ms <- NULL
  
  song_data <- df %>% filter(artist_name ==  a & track_name == c)
  
  chr <- c("artist_name","track_name","duration_min")
  vars_num <- c("danceability","energy","loudness","valence")
  
  df <- sample_frac(df, 0.1)
  
  #Vemos si la cancion esta dentro del sample que generamos
  x <- match_df(df,song_data)
  
  #Si la cancion no esta, la agregamos a nuestro dataframe
  if (nrow(x) == 0) {
    df <- rbind(df,song_data) 
  }
  
  chr_data <- df %>% select(all_of(chr))
  num_data <- df %>% select(all_of(vars_num)) %>% as.data.frame()
  df <- scale(num_data) %>% as.data.frame()
  
  modelo_kmeans <- kmeans(df, centers = 4)
  df$cluster <- modelo_kmeans$cluster %>% as.factor()
  df <- cbind(chr_data,df)
  
  clus <- df %>% filter(artist_name ==  a & track_name == c)
  df1 <- df %>% filter(cluster == clus$cluster)
  df1$cluster <- NULL
  
  chr_data1 <- df1 %>% select(all_of(chr))
  num_data1 <- df1 %>% select(all_of(vars_num)) %>% as.data.frame()
  
  modelo_kmeans1 <- kmeans(num_data1, centers = 4)
  num_data1$cluster <- modelo_kmeans1$cluster %>% as.factor()
  df1 <- cbind(chr_data1,num_data1)
  
  clus1 <- df1 %>% filter(artist_name ==  a & track_name == c)
  df_final <- df1 %>% filter(cluster == clus1$cluster)
  
  df_final <- df_final %>% select(all_of(chr))
  song_data <- song_data %>% select(all_of(chr))
  
  PlayList <- NULL
  PlayList <- rbind(PlayList,song_data)
  contador <- song_data$duration_min
  df_final <- df_final %>% filter(artist_name != a & track_name != c)
  
  while (contador < 180) {
    song_dt <- df_final[1,]
    artist <- song_dt$artist_name
    song <- song_dt$track_name
    PlayList <- rbind(PlayList,song_dt)
    contador <- contador + song_dt$duration_min
    df_final <- df_final %>% filter(artist_name != artist & track_name != song)
  }
  
  if (contador > 183) {
    n <- nrow(PlayList)
    contador <- contador - PlayList[n,]$duration_min
    PlayList <- PlayList[-c(n),]
  }
  else {
    contador <- contador
    PlayList <- PlayList
  }
  
  return(PlayList)
}

lista <- playlist(data, "Kygo", "Firestone")

print("El Playlist resultante apartir del artista y canción escogida es:")
lista

print(paste0("La duración del playlist es de ", round(sum(lista$duration_min),2), " minutos"))
