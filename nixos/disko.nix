{
  # Declarative disk layout for the NixOS dev VM.
  #
  # The partition `label`s are pinned to "EFI" and "root" so the generated
  # `fileSystems` entries reference /dev/disk/by-partlabel/{EFI,root} -- the
  # same GPT partition names the existing VM already uses. This lets the
  # layout be adopted in place without repartitioning or reformatting.
  #
  # Nothing in this file runs against a live disk unless the disko CLI
  # (destroy/format modes) is invoked explicitly, which is only done on a
  # fresh machine. On the existing VM it is evaluated for config only.
  disko.devices.disk.main = {
    # Inert on the running VM; used only when disko actually creates the disk
    # on a fresh install. Override per-machine via `--disk main /dev/...`.
    device = "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          label = "EFI";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["fmask=0077" "dmask=0077"];
          };
        };
        root = {
          size = "100%";
          label = "root";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
