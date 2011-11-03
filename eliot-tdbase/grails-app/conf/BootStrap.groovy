import grails.util.Environment
import org.lilie.services.eliot.tice.utils.BootstrapService
import org.lilie.services.eliot.tice.migrations.DbMigrationService

class BootStrap {

  BootstrapService bootstrapService
  DbMigrationService dbMigrationService

  def init = { servletContext ->

    switch (Environment.current) {
      case Environment.DEVELOPMENT:
        dbMigrationService.updateDb()
        bootstrapService.bootstrapForDevelopment()
        break
    }

  }


  def destroy = {
  }


}
