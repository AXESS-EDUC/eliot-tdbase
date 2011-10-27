import grails.util.Environment
import org.lilie.services.eliot.tice.utils.BootstrapService
import org.lilie.services.eliot.migrations.DbMigrationService

class BootStrap {

  BootstrapService bootstrapService
  DbMigrationService dbMigrationService

  def init = { servletContext ->

    dbMigrationService.updateDb()

    switch (Environment.current) {
      case Environment.DEVELOPMENT:
        bootstrapService.bootstrapForDevelopment()
        break
    }

  }


  def destroy = {
  }


}
