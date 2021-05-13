## ----include=FALSE------------------------------------------------------------
library(knitr)
opts_chunk$set(
concordance=TRUE,
eval=FALSE
)

## ----include=FALSE------------------------------------------------------------
#  library(knitr)
#  opts_chunk$set(include=TRUE,
#  engine='R',dev='pdf'
#  )

## ----preliminaries,echo=FALSE-------------------------------------------------
#  options(width=68)
#  library(BioCro, quietly=TRUE)
#  library(lattice)

## ----ex-photo-----------------------------------------------------------------
#  c4photo(1500,25,0.7)

## ----c4photo-aq-aci, warning=FALSE, fig.height=3.8, tidy=TRUE, echo=FALSE-----
#  pr <- seq(0,2000)
#  temp <- rep(25, length(pr))
#  rh <- rep(0.7, length(pr))
#  res <- c4photo(pr, temp, rh)
#  plot(pr, res$Assim, ylab="CO2 uptake",xlab="PAR",type='l')
#  Ca <- seq(15,500)
#  pr <- rep(1000, length(Ca))
#  temp <- rep(20, length(Ca))
#  rh <- rep(0.7, length(Ca))
#  res <- c4photo(pr,temp,rh,Catm=Ca)
#  plot(res$Ci, res$Assim, type = 'l', ylab = "CO2 uptake", xlab = "Ci")

## ----c4photo-tempresponse, fig.height=5---------------------------------------
#  idat <- data.frame(Qp=1500, temp = 0:50, rh = 0.7)
#  res <- c4photo(idat$Qp, idat$temp, idat$rh)
#  res2 <- c4photo(idat$Qp, idat$temp, idat$rh, uppertemp = 45, lowertemp = 10)
#  xyplot(res$Assim + res2$Assim ~ idat$temp, type = 'o',
#         xlab = "Temperature", ylab = "Assimilation",
#         key = simpleKey(c('default','U = 45, L = 10')))

## ----c4photo-stress-gs, fig.height=4.5, tidy=TRUE, echo=FALSE-----------------
#  sws <- seq(0, 1, 0.01)
#  
#  assim <- numeric(length(sws))
#  cond <- numeric(length(sws))
#  ws <- 'gs'
#  
#  for (i in seq_along(sws)) {
#      assim[i] <- c4photo(1500, 25, 0.7, StomWS=sws[i], ws=ws)$assimilation_rate
#      cond[i] <- c4photo(1500, 25, 0.7, StomWS=sws[i], ws=ws)$Gs
#  }
#  
#  xyplot(assim + cond ~ sws, type='l', auto=TRUE, main="stress on gs")

## ----c4photo-stress-vmax, fig.height=4.5, echo=FALSE--------------------------
#  sws <- seq(0,1,0.01)
#  
#  assim <- numeric(length(sws))
#  cond <- numeric(length(sws))
#  ws <- 'vmax'
#  
#  for(i in 1:length(sws)){
#  
#      assim[i] <- c4photo(1500, 25, 0.7, StomWS=sws[i],ws=ws)$assimilation_rate
#      cond[i] <- c4photo(1500, 25, 0.7, StomWS=sws[i],ws=ws)$Gs
#  
#  }
#  xyplot(assim + cond ~ sws, type='l', main="stress on vmax")
#  

## ----aq-data, fig.height=3.8--------------------------------------------------
#  data(aq)
#  head(aq)
#  lattice::xyplot(A ~ PARi | trt, data=aq, ylab='CO2 uptake', xlab='Quantum flux')

## ----curve1-------------------------------------------------------------------
#  curve1 <- subset(aq, ID == 1)

## ----Opc4photo-curve1, eval=FALSE---------------------------------------------
#  op <- Opc4photo(curve1[,3:6])
#  op

## ----Opc4photo-curve1-op2, eval=FALSE-----------------------------------------
#  op <- Opc4photo(curve1[,3:6], op.level=2)
#  op

## ----Opc4photo-plot, fig.height=3.5, eval=FALSE-------------------------------
#  plot(op)
#  plot(op, plot.kind="OandF", type="o")

## ----mOpc4photo, eval=FALSE---------------------------------------------------
#  aq2 <- data.frame(aq[,-2], Catm=390)
#  mop <- mOpc4photo(aq2, verbose=TRUE)
#  mop

## ----mOpc4photo-plot, fig.height=3.5, eval=FALSE------------------------------
#  plot(mop)
#  plot(mop, parm="alpha")

## ----mOpc4photo-op2, fig.height=3.5, eval=FALSE-------------------------------
#  mop2 <- mOpc4photo(aq2, verbose=TRUE, op.level=2)
#  mop2

## ----MCMCc4photo, fig.height=3.5, eval=FALSE----------------------------------
#  op.mc1 <- MCMCc4photo(curve1[,3:6], scale=1.5)
#  op.mc2 <- MCMCc4photo(curve1[,3:6], scale=1.5)
#  op.mc1
#  plot(op.mc1, op.mc2, plot.kind="density", burnin=1e4)
#  plot(op.mc1, plot.kind="density", prior=TRUE, burnin=1e4)

## ----MCMCc4photo-priors, fig.height=3.8, eval=FALSE---------------------------
#  op.mc1 <- MCMCc4photo(curve1[,3:6], scale=1.5, prior=c(20, 1, 0.045, 0.0025))
#  plot(op.mc1, plot.kind = "density", prior = TRUE, burnin=1e3, lwd=2)

## ----nls-photo----------------------------------------------------------------
#  c4photo2 <- function(A,T,RH, vmax=39, alpha=0.04){
#      res <- c4photo(A,T,RH, vmax=vmax, alpha=alpha)$assimilation_rate
#      res
#  }
#  fit <- nls(A ~ c4photo2(PARi, Tleaf, RH_S, vmax, alpha),
#             start=list(vmax=39, alpha=0.04),
#             data = curve1)

## ----CanA-onetime, eval=FALSE-------------------------------------------------
#  nlay <- 8
#  res <- CanA(lai=3, doy=200, hr=12, solar=1500, temp=25, rh=0.7,
#              windspeed=2, nlayers=nlay)

## ----leaf-sun-shade, eval=FALSE-----------------------------------------------
#  apply(res$LayMat[,3:4], 2, sum)

## ----multi-layer-canopy, fig.height=4.5, echo=FALSE, eval=FALSE---------------
#  data(boo14.200)
#  
#  lai <- 5
#  nlay <- 10
#  chi.l <- 1
#  lat <- 42
#  tmp2 <- NULL
#  
#  for(i in 1:24){
#    doy <- boo14.200[i,2]
#    hr  <- boo14.200[i,3]
#    solar <- boo14.200[i,4]
#    temp <- boo14.200[i,5]
#    rh <- boo14.200[i,6]
#    ws <- boo14.200[i,7]
#  
#    tmp <- CanA(lai,doy,hr,solar,temp,rh,ws,
#                nlayers=nlay,chi.l=chi.l,
#                lat = lat)$LayMat
#  
#    tmp <- cbind(hour=hr, layers=1:nlay,tmp)
#    tmp2 <- rbind(tmp2,tmp)
#  
#  }
#  
#  tmpd <- as.data.frame(tmp2)
#  
#  ttle <- paste("LAI = ",lai,
#                "   layers = ",nlay,
#                "   chi.l = ",chi.l,
#                "   lat = ",lat, sep="")
#  
#  ## Leaf in the Sun and Shade
#  xyplot(Leafsun + Leafshade ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Leaf Area (m2/m2)",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Transpiration weighted by sun and shade leaf
#  xyplot(I(TransSun*Leafsun) +
#         I(TransShade*Leafshade) ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Transpiration (kg/m2/hr)",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Assimilation weighted by sun and shade leaf
#  xyplot(I(AssimSun*Leafsun) +
#         I(AssimShade*Leafshade) ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Assimilation (micro mol /m2 ground /s)",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Leaf temperature in the sun and shade
#  xyplot(DeltaSun + DeltaShade ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Delta temperature",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Leaf level conductance
#  xyplot(CondSun + CondShade ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Conductance (mmol/m2/s)",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Relative humidity profile
#  xyplot(RH ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Relative Humidity",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Wind speed profile
#  xyplot(WindSpeed ~ hour | factor(layers), type='l',
#         xlab = "hour", ylab="Wind speed (m/s)",
#         main=ttle,
#         key=simpleKey(text=c("Sun","Shade")),
#         data = tmpd, layout=c(nlay,1))
#  
#  ## Canopy height
#  xyplot(CanopyHeight ~ layers, type='l',
#         xlab = "layer", ylab="Canopy Height (m)",
#         main=ttle,
#         data = tmpd)
#  

## ----CanA-Transpiration, echo=FALSE, eval=FALSE-------------------------------
#  ## Code to test transpiration
#  data(boo14.200)
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=3)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp2 <- as.data.frame(tmp2)
#  
#  names(tmp2) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  
#  xyplot(CanopyTrans + TranPen + TranEpries ~ 1:24, data = tmp2,
#         type='o',
#         key= simpleKey(text=c("Penman-Monteith","Penman-Potential","Priestly"),
#             lines=TRUE, points=FALSE),
#             xlab='hour',
#             ylab="Transpiration (mm/h)")
#  
#  apply(tmp2[,2:4], 2, sum)

## ----ball-berry-effect,include=FALSE, eval=FALSE------------------------------
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=3)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp3 <- as.data.frame(tmp2)
#  
#  names(tmp3) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  
#  ## Version with higher ball-berry slope
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=7)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp4 <- as.data.frame(tmp2)
#  
#  names(tmp4) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  
#  ## Version with even higher ball-berry slope
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=12)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp5 <- as.data.frame(tmp2)
#  
#  names(tmp5) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  

## ----ball-berry-priestly,echo=FALSE, eval=FALSE-------------------------------
#  xyplot(tmp5$CanopyTrans + tmp4$CanopyTrans + tmp3$CanopyTrans + tmp3$TranEpries ~ 1:24,
#         type='o', col=c(rep("blue",3),"green"), lty=c(1:3,1),
#         key= list(text=list(c("Priestly","b1=12","b1= 7","b1= 3")),
#             col=c("green",rep("blue",3)),
#             lty=c(1,1:3), pch=NA,
#             lines=TRUE, points=FALSE, x=0.1, y=0.9),
#             xlab='hour',
#             ylab="Transpiration (mm/h)")

## ----canopy-stress, include=FALSE, eval=FALSE---------------------------------
#  ## No stress
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=3)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws, StomataWS=1,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp3 <- as.data.frame(tmp2)
#  
#  names(tmp3) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  
#  ## Moderate stress
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=3)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws, StomataWS=0.8,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp4 <- as.data.frame(tmp2)
#  
#  names(tmp4) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  
#  ## medium stress
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=3)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws, StomataWS=0.5,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp5 <- as.data.frame(tmp2)
#  
#  names(tmp5) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")
#  
#  ## significant stress
#  dat2 <- NULL
#  tmp2 <- matrix(ncol=5,nrow=24)
#  layers <- 10
#  lai <- 3
#  doy <- 200
#  photoP <- photoParms(b1=3)
#  
#  for(i in 1:24){
#  
#      hr  <- boo14.200[i,3]
#      solar <- boo14.200[i,4]
#      temp <- boo14.200[i,5]
#      rh <- boo14.200[i,6]
#      ws <- boo14.200[i,7]
#  
#      tmp1 <- CanA(lai,doy,hr,solar,temp,rh,ws, StomataWS=0.3,
#                   nlayers=layers, photoControl=photoP)
#  
#      tmp2[i,1] <- tmp1$CanopyAssim
#      tmp2[i,2] <- tmp1$CanopyTrans
#      tmp2[i,3] <- tmp1$TranEpen
#      tmp2[i,4] <- tmp1$TranEpries
#      tmp2[i,5] <- tmp1$CanopyCond
#  
#      dat1 <- data.frame(hour=i,layer=1:layers,
#                         as.data.frame(tmp1$LayMat))
#  
#      dat2 <- rbind(dat2,dat1)
#  }
#  
#  tmp6 <- as.data.frame(tmp2)
#  
#  names(tmp6) <- c("CanopyAssim","CanopyTrans",
#                   "TranPen","TranEpries","CanopyCond")

## ----canopy-stress-graphs,echo=FALSE, fig.width=5, fig.height=3.2, eval=FALSE----
#  xyplot(tmp6$CanopyTrans + tmp5$CanopyTrans + tmp4$CanopyTrans + tmp3$CanopyTrans ~ 1:24,
#         type='o', col=c(rep("blue",3),"green"), lty=4:1,
#         key= list(text=list(c("stress=1","stress=0.8","stress=0.5","stress=0.3")),
#             col=c("green",rep("blue",3)),
#             lty=1:4, pch=NA,
#             lines=TRUE, points=FALSE, x=0.01, y=0.9),
#             xlab='hour',
#             ylab="Transpiration (mm/h)")
#  
#  ## What about assimilation
#  xyplot(tmp6$CanopyAssim + tmp5$CanopyAssim + tmp4$CanopyAssim + tmp3$CanopyAssim ~ 1:24,
#         type='o', col=c(rep("blue",3),"green"), lty=4:1,
#         key= list(text=list(c("stress=1","stress=0.8","stress=0.5","stress=0.3")),
#             col=c("green",rep("blue",3)),
#             lty=1:4, pch=NA,
#             lines=TRUE, points=FALSE, x=0.01, y=0.9),
#             xlab='hour',
#             ylab="Canopy Assimilation (kg/m2/h)")

## ----BioGro, eval=FALSE-------------------------------------------------------
#  data(cmi04)
#  summary(cmi04)
#  soilP <- soilParms(wsFun='linear')
#  res <- BioGro(cmi04, soilControl=soilP)
#  plot(res)
#  plot(res, plot.kind="SW")
#  plot(res, plot.kind="ET")
#  plot(res, plot.kind="cumET")
#  plot(res, plot.kind="stress")
#  names(res)

## ----BioGro-ET, echo=FALSE, eval=FALSE----------------------------------------
#  data(cmi04)
#  res.prs <- BioGro(cmi04,
#                    canopyControl = canopyParms(eteq="Priestly"))
#  res.pnm <- BioGro(cmi04,
#                    canopyControl = canopyParms(eteq="Penman"))
#  res.pnm.m <- BioGro(cmi04,
#                      canopyControl =
#                      canopyParms(eteq="Penman-Monteith"))
#  
#  et.prs <- cumsum(res.prs$CanopyTrans
#                   + res.prs$SoilEvaporation)*0.1
#  et.pnm <- cumsum(res.pnm$CanopyTrans
#                   + res.pnm$SoilEvaporation)*0.1
#  et.pnm.m <- cumsum(res.pnm.m$CanopyTrans
#                     + res.pnm.m$SoilEvaporation)*0.1
#  
#  xyplot(et.prs + et.pnm + et.pnm.m ~ res.prs$ThermalT, type='l',
#         xlab = "Thermal time", ylab = "cummulative ET (mm)",
#         key=simpleKey(c("Priestly","Penman-Potential","Penman-Monteith"),
#             lines=TRUE, points=FALSE))

## ----BioGro-ET-b1-12, echo=FALSE, eval=FALSE----------------------------------
#  photoP <- photoParms(b1=12)
#  soilP <- soilParms(soilDepth=1.5)
#  res.pnm.m.b1.12 <- BioGro(cmi04,
#                            photoControl = photoP,
#                            soilControl = soilP)
#  
#  et.pnm.m.b1.12 <- cumsum(res.pnm.m.b1.12$CanopyTrans
#                     + res.pnm.m.b1.12$SoilEvaporation)*0.1
#  
#  xyplot(et.prs + et.pnm + et.pnm.m + et.pnm.m.b1.12 ~ res.prs$ThermalT,
#         type='l', xlab = "Thermal time", ylab = "cummulative ET (mm)",
#         key=simpleKey(c("Priestly","Penman-Potential","PM b1=3",
#             "PM b1=12"), lines=TRUE, points=FALSE))

## ----BioGro-ET-no-stress, echo=FALSE, eval=FALSE------------------------------
#  photoP <- photoParms(b1=12)
#  soilP <- soilParms(wsFun='none')
#  res.pnm.m.ns <- BioGro(cmi04,
#                            photoControl = photoP,
#                            soilControl = soilP)
#  
#  et.pnm.m.ns <- cumsum(res.pnm.m.ns$CanopyTrans
#                     + res.pnm.m.ns$SoilEvaporation)*0.1
#  
#  xyplot(et.prs + et.pnm + et.pnm.m.b1.12 + et.pnm.m.ns ~ res.prs$ThermalT,
#         type='l', xlab = "Thermal time", ylab = "cummulative ET (mm)",
#         key=simpleKey(c("Priestly","Penman-Potential","Penman-Monteith",
#             "PM no stress"), lines=TRUE, points=FALSE))

## ----water-balance, eval=FALSE------------------------------------------------
#  ## Simple water budget
#  ## P - ET + RO + DR + DeltaTheta = 0
#  data(cmi04)
#  day1 <- 100
#  dayn <- 270
#  cmi04.s <- subset(cmi04, doy > 99 & doy < 271)
#  P <- sum(cmi04.s$precip) ## in mm
#  iwc <- 0.29
#  soildepth <- 2
#  soilP <- soilParms(iWatCont=iwc, soilDepth=soildepth, soilLayers=1)
#  res <- BioGro(cmi04, day1=100, dayn=270, soilControl = soilP)
#  et <- res$CanopyTrans + res$SoilEvaporation
#  ET <- sum(et) * (1/0.9982) *0.1
#  ## in mm, 0.9982 accounts for density of water
#  RO <- sum(res$Runoff) ## in mm
#  DR <- sum(res$Drainage) ## in mm
#  iTheta <- iwc * soildepth
#  fswc <- res$SoilWatCont[length(res$SoilWatCont)]
#  fswc
#  fTheta <- fswc * soildepth
#  DeltaTheta <- (fTheta - iTheta) * 1e3 ## from m to mm
#  cbind(P, ET, DeltaTheta, RO, DR)
#  P - (ET + DeltaTheta + RO + DR)

