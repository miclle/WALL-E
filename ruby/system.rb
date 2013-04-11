class System

  def self.cpu
    cpuinfo = Hash.new
    real_cpu = Hash.new
    cpu_number = 0
    current_cpu = nil

    File.open("/proc/cpuinfo").each do |line|
      case line
      when /processor\s+:\s(.+)/
        cpuinfo[$1] = Hash.new
        current_cpu = $1
        cpu_number += 1
      when /vendor_id\s+:\s(.+)/
        cpuinfo[current_cpu]["vendor_id"] = $1
      when /cpu family\s+:\s(.+)/
        cpuinfo[current_cpu]["family"] = $1
      when /model\s+:\s(.+)/
        cpuinfo[current_cpu]["model"] = $1
      when /stepping\s+:\s(.+)/
        cpuinfo[current_cpu]["stepping"] = $1
      when /physical id\s+:\s(.+)/
        cpuinfo[current_cpu]["physical_id"] = $1
        real_cpu[$1] = true
      when /core id\s+:\s(.+)/
        cpuinfo[current_cpu]["core_id"] = $1
      when /cpu cores\s+:\s(.+)/
        cpuinfo[current_cpu]["cores"] = $1
      when /model name\s+:\s(.+)/
        cpuinfo[current_cpu]["model_name"] = $1
      when /cpu MHz\s+:\s(.+)/
        cpuinfo[current_cpu]["mhz"] = $1
      when /cache size\s+:\s(.+)/
        cpuinfo[current_cpu]["cache_size"] = $1
      when /flags\s+:\s(.+)/
        cpuinfo[current_cpu]["flags"] = $1.split(' ')
      end
    end

    cpuinfo[:total] = cpu_number
    cpuinfo[:real] = real_cpu.keys.length
    cpuinfo
  end

  def self.memory
    memory = Hash.new
    memory[:swap] = Hash.new

    File.open("tmp/meminfo").each do |line|
      case line
      when /^MemTotal:\s+(\d+)/
        memory[:total] = $1.to_i
      when /^MemFree:\s+(\d+)/
        memory[:free] = $1.to_i
      when /^Buffers:\s+(\d+)/
        memory[:buffers] = $1.to_i
      when /^Cached:\s+(\d+)/
        memory[:cached] = $1.to_i
      when /^Active:\s+(\d+)/
        memory[:active] = $1.to_i
      when /^Inactive:\s+(\d+)/
        memory[:inactive] = $1.to_i
      when /^HighTotal:\s+(\d+)/
        memory[:high_total] = $1.to_i
      when /^HighFree:\s+(\d+)/
        memory[:high_free] = $1.to_i
      when /^LowTotal:\s+(\d+)/
        memory[:low_total] = $1.to_i
      when /^LowFree:\s+(\d+)/
        memory[:low_free] = $1.to_i
      when /^Dirty:\s+(\d+)/
        memory[:dirty] = $1.to_i
      when /^Writeback:\s+(\d+)/
        memory[:writeback] = $1.to_i
      when /^AnonPages:\s+(\d+)/
        memory[:anon_pages] = $1.to_i
      when /^Mapped:\s+(\d+)/
        memory[:mapped] = $1.to_i
      when /^Slab:\s+(\d+)/
        memory[:slab] = $1.to_i
      when /^SReclaimable:\s+(\d+)/
        memory[:slab_reclaimable] = $1.to_i
      when /^SUnreclaim:\s+(\d+)/
        memory[:slab_unreclaim] = $1.to_i
      when /^PageTables:\s+(\d+)/
        memory[:page_tables] = $1.to_i
      when /^NFS_Unstable:\s+(\d+)/
        memory[:nfs_unstable] = $1.to_i
      when /^Bounce:\s+(\d+)/
        memory[:bounce] = $1.to_i
      when /^CommitLimit:\s+(\d+)/
        memory[:commit_limit] = $1.to_i
      when /^Committed_AS:\s+(\d+)/
        memory[:committed_as] = $1.to_i
      when /^VmallocTotal:\s+(\d+)/
        memory[:vmalloc_total] = $1.to_i
      when /^VmallocUsed:\s+(\d+)/
        memory[:vmalloc_used] = $1.to_i
      when /^VmallocChunk:\s+(\d+)/
        memory[:vmalloc_chunk] = $1.to_i
      when /^SwapCached:\s+(\d+)/
        memory[:swap][:cached] = $1.to_i
      when /^SwapTotal:\s+(\d+)/
        memory[:swap][:total] = $1.to_i
      when /^SwapFree:\s+(\d+)/
        memory[:swap][:free] = $1.to_i
      end
    end
    memory
  end

end