Feature: Boundaries
  As a DevOps,
  I want to see the boundaries of a system
  so that I know how to interact with it.

  Scenario: Exposed ports
    Given a file named "compose.yml" with:
      """
      version: "2"
      services:
        service:
          ports:
            - 8080
      """
    When I run `bin/compose_plantuml --boundaries compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      [service] --> 8080

      """

  Scenario: Alias Ports
    Given a file named "compose.yml" with:
      """
      version: "2"
      services:
        service:
          ports:
            - 8080:80
      """
    When I run `bin/compose_plantuml --boundaries compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      [service] --> 8080 : 80

      """

  Scenario: Volumes
    Given a file named "compose.yml" with:
      """
      version: "2"
      services:
        service:
          volumes:
            - service_log:/log
      volumes:
        service_log: {}
      """
    When I run `bin/compose_plantuml --boundaries compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      database service_log {
        [/log] as volume_1
      }
      [service] --> volume_1

      """

  Scenario: Filter internal services
    Given a file named "compose.yml" with:
      """
      version: "2"
      services:
        service:
          volumes:
            - service_log:/log
        unused_service: {}
      volumes:
        service_log: {}
        unused_volume: {}
      """
    When I run `bin/compose_plantuml --boundaries compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      database service_log {
        [/log] as volume_1
      }
      [service] --> volume_1

      """

  Scenario: Group Volumes and Ports
    Given a file named "compose.yml" with:
      """
      version: "2"
      services:
        service:
          volumes:
            - service_log:/log
          ports:
           - 8080:80
        unused_service: {}
      volumes:
        service_log: {}
        unused_volume: {}
      """
    When I run `bin/compose_plantuml --boundaries --group compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      package volumes {
        database service_log {
          [/log] as volume_1
        }
      }
      package ports {
        interface 8080
      }
      [service] --> 8080 : 80
      [service] --> volume_1

      """

  Scenario: Notes
    Given a file named "compose.yml" with:
      """
      version: "2"
      services:
        service:
          volumes:
            - service_log:/log
          labels:
            key:value
      volumes:
        service_log: {}
      """
    When I run `bin/compose_plantuml --boundaries --notes compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      database service_log {
        [/log] as volume_1
      }
      [service] --> volume_1
      note top of [service]
        key=value
      end note
      """

  Scenario: Suppport for legacy docker-compose format
    Given a file named "compose.yml" with:
      """
      service:
        ports:
          - 8080:80
      """
    When I run `bin/compose_plantuml --boundaries compose.yml`
    Then it should pass with exactly:
      """
      skinparam componentStyle uml2
      cloud system {
        [service]
      }
      [service] --> 8080 : 80

      """
