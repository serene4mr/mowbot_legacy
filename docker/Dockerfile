ARG BASE_IMAGE

FROM $BASE_IMAGE AS base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG ROS_DISTRO
ENV CCACHE_DIR="/root/.ccache"

# Copy files
COPY setup-dev-env.sh amd64.env arm64.env py_requirements.txt /mowbot_legacy/
COPY docker/scripts/cleanup_apt.sh /mowbot_legacy/cleanup_apt.sh
RUN chmod +x /mowbot_legacy/cleanup_apt.sh
COPY docker/scripts/resolve_rosdep_keys.sh /mowbot_legacy/resolve_rosdep_keys.sh
RUN chmod +x /mowbot_legacy/resolve_rosdep_keys.sh
COPY docker/scripts/build_and_clean.sh /mowbot_legacy/build_and_clean.sh
RUN chmod +x /mowbot_legacy/build_and_clean.sh
RUN chmod +x /mowbot_legacy/setup-dev-env.sh

WORKDIR /mowbot_legacy

# Install apt packages and add GitHub to known hosts for private repositories
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
  && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  gosu \
  ssh \
  ccache \
  libqt5serialport5-dev \
  python3-tk \
  psmisc \
  && /mowbot_legacy/cleanup_apt.sh \
  && mkdir -p ~/.ssh \
  && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Set up base environment
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  ./setup-dev-env.sh -y \
  && /mowbot_legacy/cleanup_apt.sh \
  && echo "source /opt/ros/${ROS_DISTRO}/setup.bash" > /etc/bash.bashrc

# Install Foxglove Bridge package
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    git clone https://github.com/serene4mr/foxglove-bridge-pkg-0.8.5.git /tmp/foxglove-bridge-pkg \
    && cp -r /tmp/foxglove-bridge-pkg/* /opt/ros/${ROS_DISTRO}/ \
    && rm -rf /tmp/foxglove-bridge-pkg

# Copy source and Generate install package lists
COPY src /mowbot_legacy/src
RUN /mowbot_legacy/resolve_rosdep_keys.sh /mowbot_legacy/src ${ROS_DISTRO} \
  > /tmp/rosdep-main-depend-packages.txt \
  && cat /tmp/rosdep-main-depend-packages.txt

# Install rosdep dependencies
# hadolint ignore=SC2002
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  apt-get update \
  && cat /tmp/rosdep-main-depend-packages.txt| xargs apt-get install -y --no-install-recommends \
  && /mowbot_legacy/cleanup_apt.sh

# Install Python packages
RUN pip install --no-cache-dir -r /mowbot_legacy/py_requirements.txt

# hadolint ignore=SC1091
RUN --mount=type=cache,target=${CCACHE_DIR} \
    # --mount=type=bind,source=/src,target=/mowbot_legacy/src \
  source /opt/ros/"$ROS_DISTRO"/setup.bash \
  && /mowbot_legacy/build_and_clean.sh ${CCACHE_DIR} /opt/mowbot_legacy

# Create entrypoint
COPY docker/etc/ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

