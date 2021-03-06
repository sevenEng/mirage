(*
 * Copyright (c) 2013 Thomas Gazagnaire <thomas@gazagnaire.org>
 * Copyright (c) 2013 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

(** Mirage combinators.

    [Mirage] devices a set of devices and combinator to to define
    portable applications across all platforms that MirageOS
    supports.

   {e Release %%VERSION%% } *)


(** Configuration keys. *)
module Key : module type of struct include Mirage_key end

include Functoria_app.DSL

(** {2 General mirage devices} *)

type tracing
(** The type for tracing. *)

val tracing: tracing typ
(** Implementation of the {!tracing} type. *)

val mprof_trace : size:int -> unit -> tracing impl
(** Use mirage-profile to trace the unikernel. On Unix, this creates
    and mmaps a file called "trace.ctf". On Xen, it shares the trace
    buffer with dom0.

    @param size: size of the ring buffer to use. *)



(** {2 Time} *)

type time
(** Abstract type for timers. *)

val time: time typ
(** Implementations of the [V1.TIME] signature. *)

val default_time: time impl
(** The default timer implementation. *)



(** {2 Clocks} *)

type pclock
(** Abstract type for POSIX clocks. *)

val pclock: pclock typ
(** Implementations of the {!V1.PCLOCK} signature. *)

val default_posix_clock: pclock impl
(** The default mirage-clock PCLOCK implementation. *)

type mclock
(** Abstract type for monotonic clocks *)

val mclock: mclock typ
(** Implementations of the {!V1.MCLOCK} signature. *)

val default_monotonic_clock: mclock impl
(** The default mirage-clock MCLOCK implementation. *)



(** {2 Log reporters} *)

type reporter
(** The type for log reporters. *)

val reporter: reporter typ
(** Implementation of the log {!reporter} type. *)

val default_reporter:
  ?clock:pclock impl -> ?ring_size:int -> ?level:Logs.level ->
  unit -> reporter impl
(** [default_reporter ?clock ?level ()] is the log reporter that
    prints log messages to the console, timestampted with [clock]. If
    not provided, the default clock is {!default_posix_clock}. [level] is
    the default log threshold. It is [Logs.Info] if not
    specified. *)

val no_reporter: reporter impl
(** [no_reporter] disable log reporting. *)



(** {2 Random} *)

type random
(** Abstract type for random sources. *)

val random: random typ
(** Implementations of the [V1.RANDOM] signature. *)

val stdlib_random: random impl
(** Passthrough to the OCaml Random generator. *)

val nocrypto_random: random impl
(** Passthrough to the Fortuna PRNG implemented in nocrypto. *)


(** {2 Consoles} *)

type console
(** Abstract type for consoles. *)

val console: console typ
(** Implementations of the [V1.CONSOLE] signature. *)

val default_console: console impl
(** Default console implementation. *)

val custom_console: string -> console impl
(** Custom console implementation. *)



(** {2 Memory allocation interface} *)

type io_page
(** Abstract type for page-aligned buffers. *)

val io_page: io_page typ
(** Implementations of the [V1.IO_PAGE] signature. *)

val default_io_page: io_page impl
(** The default [Io_page] implementation. *)



(** {2 Block devices} *)


type block
(** Abstract type for raw block device configurations. *)

val block: block typ
(** Implementations of the [V1.BLOCK] signature. *)

val block_of_file: string -> block impl
(** Use the given filen as a raw block device. *)



(** {2 Static key/value stores} *)

type kv_ro
(** Abstract type for read-only key/value store. *)

val kv_ro: kv_ro typ
(** Implementations of the [V1.KV_RO] signature. *)

val crunch: string -> kv_ro impl
(** Crunch a directory. *)

val archive: block impl -> kv_ro impl

val archive_of_files: ?dir:string -> unit -> kv_ro impl

val direct_kv_ro: string -> kv_ro impl
(** Direct access to the underlying filesystem as a key/value
    store. For Xen backends, this is equivalent to [crunch]. *)



(** {2 Filesystem} *)


type fs
(** Abstract type for filesystems. *)

val fs: fs typ
(** Implementations of the [V1.FS] signature. *)

val fat: ?io_page:io_page impl -> block impl -> fs impl
(** Consider a raw block device as a FAT filesystem. *)

val fat_of_files: ?dir:string -> ?regexp:string -> unit -> fs impl
(** [fat_files dir ?dir ?regexp ()] collects all the files matching
    the shell pattern [regexp] in the directory [dir] into a FAT
    image. By default, [dir] is the current working directory and
    [regexp] is {i *} *)

val kv_ro_of_fs: fs impl -> kv_ro impl
(** Consider a filesystem implementation as a read-only key/value
    store. *)

(** {2 Generic key/value stores} *)

val generic_kv_ro :
  ?key:[ `Archive | `Crunch | `Direct | `Fat ] value -> string -> kv_ro impl
(** Generic key/value that will choose dynamically between
    {!fat}, {!archive} and {!crunch}.  To use a filesystem implementation,
    try {!kv_ro_of_fs}.

    If no key is provided, it uses {!Key.kv_ro} to create a new one.
*)


(** {2 Network interfaces} *)


type network
(** Abstract type for network configurations. *)

val network: network typ
(** Implementations of the [V1.NETWORK] signature. *)

val tap0: network impl
(** The '/dev/tap0' interface. *)

val netif: ?group:string -> string -> network impl
(** A custom network interface. Exposes a {!Key.network} key. *)



(** {2 Ethernet configuration} *)

type ethernet

val ethernet : ethernet typ
(** Implementations of the [V1.ETHIF] signature. *)

val etif: network impl -> ethernet impl

(** {2 ARP configuration} *)

type arpv4

val arpv4 : arpv4 typ
(** Implementation of the [V1.ARPV4] signature. *)

val arp: ?clock: mclock impl -> ?time: time impl -> ethernet impl -> arpv4 impl

(** {2 IP configuration}

    Implementations of the [V1.IP] signature. *)

type v4
type v6

(** Abstract type for IP configurations. *)
type 'a ip
type ipv4 = v4 ip
type ipv6 = v6 ip

val ipv4: ipv4 typ
(** The [V1.IPV4] module signature. *)

val ipv6: ipv6 typ
(** The [V1.IPV6] module signature. *)

type ('ipaddr, 'prefix) ip_config = {
  address: 'ipaddr;
  netmask: 'prefix;
  gateways: 'ipaddr list;
}
(** Types for IP manual configuration. *)

type ipv4_config = (Ipaddr.V4.t, Ipaddr.V4.t) ip_config
(** Types for IPv4 manual configuration. *)

val create_ipv4:
  ?clock:mclock impl -> ?time:time impl ->
  ?group:string -> network impl -> ipv4_config -> ipv4 impl
(** Use an IPv4 address.
    Exposes the keys {!Key.V4.ip}, {!Key.V4.netmask} and {!Key.V4.gateways}.
*)

val default_ipv4: ?group:string -> network impl -> ipv4 impl
(** Default local IP listening on the given network interfaces:
    - address: 10.0.0.2
    - netmask: 255.255.255.0
    - gateways: [10.0.0.1] *)

type ipv6_config = (Ipaddr.V6.t, Ipaddr.V6.Prefix.t list) ip_config
(** Types for IPv6 manual configuration. *)

val create_ipv6:
  ?time:time impl -> ?clock:mclock impl ->
  ?group:string -> network impl -> ipv6_config -> ipv6 impl
(** Use an IPv6 address.
    Exposes the keys {!Key.V6.ip}, {!Key.V6.netmask} and {!Key.V6.gateways}.
*)



(** {2 UDP configuration} *)

type 'a udp
type udpv4 = v4 udp
type udpv6 = v6 udp

(** Implementation of the [V1.UDP] signature. *)
val udp: 'a udp typ
val udpv4: udpv4 typ
val udpv6: udpv6 typ

val direct_udp: 'a ip impl -> 'a udp impl

val socket_udpv4: ?group:string -> Ipaddr.V4.t option -> udpv4 impl



(** {2 TCP configuration} *)

type 'a tcp
type tcpv4 = v4 tcp
type tcpv6 = v6 tcp

(** Implementation of the [V1.TCP] signature. *)
val tcp: 'a tcp typ
val tcpv4: tcpv4 typ
val tcpv6: tcpv6 typ

val direct_tcp:
  ?clock:mclock impl ->
  ?random:random impl ->
  ?time:time impl ->
  'a ip impl -> 'a tcp impl

val socket_tcpv4: ?group:string -> Ipaddr.V4.t option -> tcpv4 impl



(** {2 Network stack configuration} *)

type stackv4

val stackv4: stackv4 typ
(** Implementation of the [V1.STACKV4] signature. *)

(** Same as {!direct_stackv4_with_static_ipv4} with the default given by
    {!default_ipv4}. *)
val direct_stackv4_with_default_ipv4:
  ?clock:mclock impl ->
  ?random:random impl ->
  ?time:time impl ->
  ?group:string ->
  network impl -> stackv4 impl

(** Direct network stack with ip.
    Exposes the keys {!Key.V4.ip}, {!Key.V4.netmask} and {!Key.V4.gateways}. *)
val direct_stackv4_with_static_ipv4:
  ?clock:mclock impl ->
  ?random:random impl ->
  ?time:time impl ->
  ?group:string ->
  network impl -> ipv4_config -> stackv4 impl

(** Direct network stack using dhcp. *)
val direct_stackv4_with_dhcp:
  ?clock:mclock impl ->
  ?random:random impl ->
  ?time:time impl ->
  ?group:string ->
  network impl -> stackv4 impl

(** Network stack with sockets. Exposes the key {Key.interfaces}. *)
val socket_stackv4:
  ?group:string -> Ipaddr.V4.t list -> stackv4 impl

(** Generic stack using a [dhcp] and a [net] keys: {!Key.net} and {!Key.dhcp}.
    - If [net] = [socket] then {!socket_stackv4} is used.
    - Else, if [dhcp] then {!direct_stackv4_with_dhcp} is used
    - Else, {!direct_stackv4_with_default_ipv4} is used.

    If a key is not provided, it uses {!Key.net} or {!Key.dhcp} (with the
    [group] argument) to create it.
*)
val generic_stackv4 :
  ?group:string ->
  ?dhcp_key:bool value ->
  ?net_key:[ `Direct | `Socket ] value ->
  network impl -> stackv4 impl

(** {2 Resolver configuration} *)

type resolver
val resolver: resolver typ
val resolver_dns :
  ?ns:Ipaddr.V4.t -> ?ns_port:int -> ?time:time impl -> stackv4 impl -> resolver impl
val resolver_unix_system : resolver impl

(** {2 Entropy} *)

val nocrypto : job impl
(** Device that initializes the entropy. *)

(** {2 Conduit configuration} *)

type conduit
val conduit: conduit typ
val conduit_direct : ?tls:bool -> stackv4 impl -> conduit impl

(** {2 HTTP configuration} *)

type http
val http: http typ
val http_server: conduit impl -> http impl

(** {2 Argv configuration} *)

val default_argv: Functoria_app.argv impl
(** [default_argv] is a dynamic argv implementation that resolves
    either to the xen or the unix implementation. *)

val no_argv: Functoria_app.argv impl
(** [no_argv] Disable command line parsing and set argv to [|""|]. *)

(** {2 Other devices} *)

val noop: job impl
(** [noop] is a job that does nothing, has no dependency and returns [()] *)

type info
(** [info] is the type for module implementing
    {!Mirage_runtime.Info}. *)

val info: info typ
(** [info] is the combinator to generate {!info} values to use at
    runtime. *)

val app_info: info impl
(** [app_info] exports all the information available at configure time
    into a runtime {!Mirage.Info.t} value. *)

(** {2 Application registering} *)

val register :
  ?argv:Functoria_app.argv impl ->
  ?tracing:tracing impl ->
  ?reporter:reporter impl ->
  ?keys:Key.t list ->
  ?libraries:string list ->
  ?packages:string list -> string -> job impl list -> unit
(** [register name jobs] registers the application named by [name]
    which will executes the given [jobs].
    @param libraries The ocamlfind libraries needed by this module.
    @param packages The opam packages needed by this module.
    @param keys The keys related to this module.

    @param tracing Enable tracing.

    @param reporter Configure logging. The default log reporter is
    {!default_reporter}. To disable logging, use {!no_reporter}.

    @param argv Configure command-line argument parsing. The default
    parser is {!default_argv}. To disable command-line parsing, use
    {!no_argv}.
*)


(**/**)

val run : unit -> unit
