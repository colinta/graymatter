module GM
  module FuncTools
    module_function

    def after(n, *args, &blk)
      if n == 0
        ret = lambda { |*args| }
        blk.call(*args)
      else
        ret = lambda { |*args|
          n -= 1
          if n == 0
            blk.call(*args)
          end
        }
      end
      return ret
    end

    def until(n, &blk)
      ret = lambda { |*args|
        if n > 0
          blk.call(*args)
        end
        n -= 1
      }
      return ret
    end

    def once(&blk)
      called = false
      ret = lambda { |*args|
        unless called
          blk.call(*args)
        end
        called = true
      }
      return ret
    end

    def CFMain(&blk)
      CFRunLoopPerformBlock(CFRunLoopGetMain(), KCFRunLoopCommonModes, blk)
    end

    module Decorators
      module_function
      def CFMain
        lambda { |inside, *args, &blk|
          FuncTools.CFMain { inside.call(*args, &blk) }
        }
      end

      def logs(name)
        lambda { |method, *args, &blk|
          NSLog("calling #{name}")
          method.call(*args, &blk)
        }
      end
    end

  end
end
