# SuperCollider for Raspberry Pi

SuperCollider, compiled for use in an Arm Docker container.

Github repository: https://github.com/orbsmiv/docker-SuperCollider-rpi

## Usage
### Running scsynth

The basic command for starting a container is as follows:
```
docker run --init -d --name scsynth --ulimit memlock=-1 --ulimit rtprio=99 --device /dev/snd -p 57110:57110/udp orbsmiv/supercollider-rpi
```
If no commands are sent to this container then it will run scsynth, as per the default options detailed below. This approach is appropriate if you wish to connect to the running instance of `scsynth` on the Raspberry Pi from a remote system. (See below for further details.)

### Running sclang

sclang can be run in an interactive container by passing the `sclang` command when the container is spawned, for example:
```
docker run --init -it --rm --name sclang_interactive --ulimit memlock=-1 --ulimit rtprio=99 --device /dev/snd -p 57110:57110/udp orbsmiv/supercollider-rpi sclang
```

One could also pass the name of a file to sclang – this might be useful for e.g. running an installation (note the volume mount):
```
docker run --init -d --name my_installation --restart unless-stopped --ulimit memlock=-1 --ulimit rtprio=99 --device /dev/snd -p 57110:57110/udp -v /home/pi/my_sc_code:/sc-workdir orbsmiv/supercollider-rpi sclang /sc-workdir/marvellous_installation.scd
```

N.B. if writing an `.scd` file for use in this scenario then you'll probably want to use `s.waitForBoot()` (or similar) in your script.

## Making a remote connection to an `scsynth` container
To connect from a SuperCollider IDE (v3.9.0 and above), run something such as the code below. Note that the ServerOptions must match those declared in the environment variables defined in the section below:
```
(
o = ServerOptions.new;
o.initialNodeID = 1000;
o.blockSize = 128;
o.memSize = 131072;
o.numInputBusChannels = 2;
o.numOutputBusChannels = 2;
o.zeroConf = 0;

s = Server.remote(\scsynth_rpi, NetAddr("0.0.0.0", 57110), o);
Server.default = s;
s.notify;
s.initTree;
)
```

Ensure that you replace `"0.0.0.0"` with the IP address of your Raspberry Pi.

## Environment Variables

The following environment variables can be passed via `docker run` (or in a docker-compose.yml file):

#### `CH_OUT`
The number of audio output channels from your container. Please note that you must choose an appropriate value for your audio hardware. (Default: 2)

#### `CH_IN`
The number of audio input channels to your container. Please note that you must choose an appropriate value for your audio hardware. (Default: 2)

#### `SC_SYNTH_PORT`
The port number on which to run scsynth. (Default: 57110)
If you change this value you'll need to reflect it in the `docker run` port assignment, e.g. `-p 57110:57110/udp`.

#### `SR`
The sample rate (in Hz) at which to run. (Default: 48000)

#### `SC_BLOCK`
Scsynth's block size (corresponding to the `-z` option) – must be 2^n. (Default: 128)

#### `HW_BUFF`
The audio hardware buffer size (defined for jackd) – must be 2^n. (Default: 2048)

#### `SC_MEM`
The real time memory size for scsynth (corresponding to the `-m` option). (Default: 131072)

## Default commands
Running with the default environment variables is the equivalent to the following options for `jackd` and `scsynth`:

`jackd -m -R -p 32 -T -d alsa -d hw:0 -n 3 -i 2 -o 2 -p 2048 -P -r 48000 -s`

`scsynth -u 57110 -m 131072 -D 0 -R 0 -i 2 -o 2 -z 128`
