module Monomer
  class Listener
    def self.monome
      Monome.monome
    end
    
    extend Core::Timer
    
    def self.loop_on_button_sustain(x=:any, y=:any, &block)
      postfix = determine_postfix(x,y)
      
      meta_def "listen_for_button_sustain_on do#{postfix}" do |x,y|
        @key_threads[[x,y]] = Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          loop do
            block.call(x,y)
          end
        end
      end
      
      meta_def "listen_for_button_sustain_off#{postfix}" do |x,y|
        if thread = @key_threads[[x,y]]
          thread.kill
          @key_threads[[x,y]] = nil
        end
      end
    end
    
    def self.before_start(&block)
      meta_def :listen_for_before_start do
        block.call
      end
    end
    
    def self.on_start(&block)
      meta_def :listen_for_start do
        thread = Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call
        end
      end
    end
    
    def self.loop_on_start(&block)
      meta_def :listen_for_loop_on_start do
        thread = Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          loop do
            block.call
          end
        end
      end
    end
    
    def self.on_button_press(x=:any, y=:any, &block)
      postfix = determine_postfix(x,y)
      
      meta_def "listen_for_button_pressed#{postfix}" do |x,y|
        Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call(x,y)
        end
      end
    end
    
    def self.on_button_release(x=:any, y=:any, &block)
      postfix = determine_postfix(x,y)
      
      meta_def "listen_for_button_released#{postfix}" do |x,y|
        Thread.new do
          change_to_s_of_this_thread_to_map_to_calling_class
          block.call(x,y)
        end
      end
    end
    
    def self.init
      @key_threads = {}
      puts methods.sort - Class.new.methods
      self  
    end
    
    def self.change_to_s_of_this_thread_to_map_to_calling_class
      current_thread = Thread.current
      method_def = <<-END
        def current_thread.to_s
          "Thread for #{self}"
        end
      END
      eval method_def
    end
    
    def self.determine_postfix(x,y)
      x = x || :any
      y = y || :any
      
      postfix = ''
      unless (x == :any && y == :any)
        postfix << "_#{x}"
        postfix << "_#{y}"
      end
      postfix
    end
    
  end
end