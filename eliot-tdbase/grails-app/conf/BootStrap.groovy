import grails.util.Environment
import org.lilie.services.eliot.tice.misc.BootstrapService

class BootStrap {

  BootstrapService bootstrapService

  def init = { servletContext ->

    switch (Environment.current) {
      case Environment.DEVELOPMENT:
        bootstrapService.bootstrapForDevelopment()
        break
    }

  }


  def destroy = {
  }


}
