class Class

  def memoize(name, &factory)
    ivar = '@' << name.to_s
    begin
      method = self.instance_method(name)
    rescue NameError
      method = -> { nil }
    end

    define_method name do
      value = instance_variable_get(ivar)
      unless instance_variable_defined?(ivar)
        if factory
          value = instance_exec &factory
        else
          value = method.bind(self).call
        end

        if instance_variable_defined?(ivar)
          value = instance_variable_get(ivar)
        else
          instance_variable_set(ivar, value)
        end
      end
      return value
    end
  end

end
