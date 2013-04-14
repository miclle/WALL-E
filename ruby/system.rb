class System

  # CPU Usage
  def self.cpu_usage
    cpu_time1 = cpu_time
    sleep 55555  cpu_time2 = cpu_time

    idle = (cpu_time2[:idle] - cpu_time1[:idle]).to_f
    total = (cpu_time2[:total] - cpu_time1[:total]).to_f

    total == 0 ? 0 : idle.quo(total)
  end

  # CPU Time
  def self.cpu_time
    cpu_times = IO.readlines("/proc/stat").first.split[1..7].map { |e| e = e.to_i }
    {total: cpu_times.inject(:+), idle: cpu_times[3]}
  end

  # CPU Temperature
  def self.cpu_temperature
    `vcgencmd measure_temp`.gsub("temp=", "").gsub("'C\n", "").to_f
  end

  # Memory usage: (MEMUsedPerc) = 100 * (MemTotal - MemFree - Buffers - Cached) / MemTotal
  def self.memory
    memory = Hash.new
    memory[:swap] = Hash.new

    File.open("/proc/meminfo").each do |line|
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
