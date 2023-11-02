# Dockerfile for building TOPAS
FROM debian:bullseye-slim 

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
        python3-pip python-is-python3 wget git vim build-essential \
        cmake bash tar unzip \
        libexpat1-dev libgl1-mesa-dev libglu1-mesa-dev xorg-dev libharfbuzz-dev \
        qt5-qmake qtbase5-dev qtbase5-dev-tools \
        libxt-dev && \
    apt-get autoremove

RUN pip install --upgrade pip

ENV HOME=/root
ENV TOPASDIR=$HOME/topas_3_9
ENV TOPAS_G4_DATA_DIR=$HOME/G4Data
ENV Geant4_DIR=$HOME/geant4.10.07.p03/install
ENV GDCM_DIR=$HOME/gdcm/install
ENV EXT_DIR=$HOME/topas_extensions/
ENV PATH="${PATH}:$TOPASDIR/install/bin"

# Copy topas source code downloaded from topasmc.org
COPY topas_3_9.zip $HOME/
RUN cd $HOME && \
    unzip topas_3_9.zip

# download and patch geant4
RUN cd $HOME && \
    wget https://geant4-data.web.cern.ch/geant4-data/releases/geant4.10.07.p03.tar.gz && \
    tar -xf geant4.10.07.p03.tar.gz && \
    patch -p0 < $TOPASDIR/patches/geant4_10_07_p03.patch

# install geant4 (Note: uses a lot of memory and hangs if number of processes is raised)
RUN cd $HOME && \
    cd geant4.10.07.p03 && \
    mkdir build && \
    cd build && \
    cmake -DGEANT4_INSTALL_DATA=OFF \
          -DGEANT4_USE_QT=ON \
          -DGEANT4_BUILD_MULTITHREADED=ON \
          -DCMAKE_INSTALL_PREFIX=~/geant4.10.07.p03/install \
          -DGEANT4_USE_OPENGL_X11=ON \
          -DGEANT4_USE_RAYTRACER_X11=ON \
          ../ && \
    make -j 2 install

# Clone and install gdcm
RUN cd $HOME && \
    git clone https://github.com/malaterre/GDCM && \
    cd GDCM && \
    mkdir build && \
    cd build && \
    cmake -DGDCM_BUILD_SHARED_LIBS=ON \
          -DGDCM_BUILD_DOCBOOK_MANPAGES:BOOL=OFF \
          -DCMAKE_INSTALL_PREFIX=~/gdcm/install \
          ../ && \
    make -j 4 install

# Download geant4 data
RUN cd $HOME && \
    mkdir $TOPAS_G4_DATA_DIR && \
    cd $TOPAS_G4_DATA_DIR && \
    wget https://geant4-data.web.cern.ch/geant4-data/datasets/G4NDL.4.6.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4EMLOW.7.13.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4PhotonEvaporation.5.7.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4RadioactiveDecay.5.6.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4PARTICLEXS.3.1.1.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4SAIDDATA.2.0.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4ABLA.3.1.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4INCL.1.0.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4PII.1.3.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4ENSDFSTATE.2.3.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4RealSurface.2.2.tar.gz \
         https://geant4-data.web.cern.ch/geant4-data/datasets/G4TENDL.1.3.2.tar.gz && \
    for d in $(ls G4*); do tar -xvf $d; done; \
    rm *.tar.gz;

# -DTOPAS_EXTENSIONS_DIR=$EXT_DIR \
# Copy topas source code downloaded from topasmc.org
RUN cd $HOME/topas_3_9 && \
    export CMAKE_PREFIX_PATH="/usr/lib/qt5/bin" && \
    mkdir build && \
    cd build && \
    cmake -DTOPAS_TYPE=public \
          -DCMAKE_PREFIX_PATH="~/geant4.10.07.p03/build/source/externals/ptl/include" \
          -DCMAKE_INSTALL_PREFIX="$TOPASDIR/install" \
          ../ && \
    make -j 4 install

COPY run_topas_on_container.sh $HOME/
