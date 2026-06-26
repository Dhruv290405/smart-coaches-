$query = @"
mutation {
  templateDeployV2(input: {
    projectId: "556c27f6-efaf-4042-bfb7-7b4deb7f44a2"
    environmentId: "fd63b9ff-ae64-4d95-ad57-42922946325e"
    templateId: "672d062a-37ef-4830-a46b-dee6e2191c38"
    serializedConfig: {
      services: {
        "mysql-service": {
          icon: "https://devicons.railway.app/i/mysql.svg"
          name: "MySQL"
          build: {}
          deploy: {
            startCommand: "docker-entrypoint.sh mysqld --innodb-use-native-aio=0 --disable-log-bin --performance_schema=0 --innodb-buffer-pool-size=1G"
            healthcheckPath: null
            requiredMountPath: "/var/lib/mysql"
          }
          source: {
            image: "mysql:9.4"
          }
          variables: {
            MYSQLHOST: { defaultValue: "`${{RAILWAY_PRIVATE_DOMAIN}}" }
            MYSQLPORT: { defaultValue: "3306" }
            MYSQLUSER: { defaultValue: "root" }
            MYSQL_URL: { defaultValue: "mysql://`${{ MYSQLUSER }}:`${{ MYSQL_ROOT_PASSWORD }}@`${{ RAILWAY_PRIVATE_DOMAIN }}:3306/`${{ MYSQL_DATABASE }}" }
            MYSQLDATABASE: { defaultValue: "`${{ MYSQL_DATABASE }}" }
            MYSQLPASSWORD: { defaultValue: "`${{ MYSQL_ROOT_PASSWORD }}" }
            MYSQL_DATABASE: { defaultValue: "railway" }
            MYSQL_PUBLIC_URL: { defaultValue: "mysql://`${{ MYSQLUSER }}:`${{ MYSQL_ROOT_PASSWORD }}@`${{ RAILWAY_TCP_PROXY_DOMAIN }}:`${{ RAILWAY_TCP_PROXY_PORT }}/`${{ MYSQL_DATABASE }}" }
            MYSQL_ROOT_PASSWORD: { isOptional: false description: "Root password for MySQL DB." defaultValue: "railway123" }
          }
          networking: {
            tcpProxies: {
              "3306": {}
            }
            serviceDomains: {}
          }
          volumeMounts: {
            "mysql-volume": {
              mountPath: "/var/lib/mysql"
            }
          }
        }
      }
    }
  }) {
    id
  }
}
"@

$body = @{ query = $query } | ConvertTo-Json -Depth 10
Write-Host $body
