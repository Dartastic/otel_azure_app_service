// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_app_service/otel_azure_app_service.dart';

/// Traces Azure App Service calls with OpenTelemetry.
///
/// `otel_azure_app_service` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure App Service call in
/// [tracedAzureAppService]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-app-service-example');

  // Traces a Azure App Service call.
  final azureAppServiceId = await tracedAzureAppService<String>(
    operation: 'create',
    invoke: () async {
      // Make the Azure App Service call here, then report what it returned.
      const id = 'azure_app_service_8f3a2c';
      return const AzureAppServiceCallResult(
          value: id,
          result: AzureAppServiceResult(
              subscriptionId: 'subscription_8f3a2c',
              resourceGroup: 'Order',
              region: 'us-east-1',
              siteName: 'example',
              slotName: 'example',
              appServicePlan: 'example',
              skuName: 'example',
              skuTier: 'example',
              instanceId: 'instance_8f3a2c',
              runtimeStack: 'example',
              runtimeVersion: '1',
              operatingSystem: 'example',
              deploymentId: 'deployment_8f3a2c',
              deploymentStatus: 'succeeded',
              deploymentSource: 'example',
              coldStart: true,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAzureAppService create returned $azureAppServiceId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureAppServiceInstrumentationAsync.
  await runWithoutAzureAppServiceInstrumentationAsync(
    () => tracedAzureAppService<String>(
      operation: 'create',
      invoke: () async {
        const id = 'azure_app_service_8f3a2c';
        return const AzureAppServiceCallResult(
            value: id,
            result: AzureAppServiceResult(
                subscriptionId: 'subscription_8f3a2c',
                resourceGroup: 'Order',
                region: 'us-east-1',
                siteName: 'example',
                slotName: 'example',
                appServicePlan: 'example',
                skuName: 'example',
                skuTier: 'example',
                instanceId: 'instance_8f3a2c',
                runtimeStack: 'example',
                runtimeVersion: '1',
                operatingSystem: 'example',
                deploymentId: 'deployment_8f3a2c',
                deploymentStatus: 'succeeded',
                deploymentSource: 'example',
                coldStart: true,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
