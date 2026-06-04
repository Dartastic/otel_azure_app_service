// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_azure_app_service_suppression.dart';

class AzureAppServiceResult {
  const AzureAppServiceResult({
    this.subscriptionId,
    this.resourceGroup,
    this.region,
    this.siteName,
    this.slotName,
    this.appServicePlan,
    this.skuName,
    this.skuTier,
    this.instanceId,
    this.runtimeStack,
    this.runtimeVersion,
    this.operatingSystem,
    this.deploymentId,
    this.deploymentStatus,
    this.deploymentSource,
    this.coldStart,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? subscriptionId;
  final String? resourceGroup;
  final String? region;
  final String? siteName;
  final String? slotName;
  final String? appServicePlan;
  final String? skuName;
  final String? skuTier;
  final String? instanceId;
  final String? runtimeStack;
  final String? runtimeVersion;
  final String? operatingSystem;
  final String? deploymentId;
  final String? deploymentStatus;
  final String? deploymentSource;
  final bool? coldStart;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AzureAppServiceCallResult<T> {
  const AzureAppServiceCallResult({required this.value, this.result});
  final T value;
  final AzureAppServiceResult? result;
}

Future<T> tracedAzureAppService<T>({
  required String operation,
  required Future<AzureAppServiceCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (azureAppServiceInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_azure_app_service');
  final span =
      t.startSpan('azure_app_service $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'azure')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.service', 'AppService')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.method', operation)]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.subscriptionId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.subscription.id', res.subscriptionId!)
        ]));
      }
      if (res.resourceGroup != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.resource_group', res.resourceGroup!)
        ]));
      }
      if (res.region != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('azure.region', res.region!)]));
      }
      if (res.siteName != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.app_service.site.name', res.siteName!)
        ]));
      }
      if (res.slotName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('azure.app_service.slot', res.slotName!)]));
      }
      if (res.appServicePlan != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'azure.app_service.plan.name', res.appServicePlan!)
        ]));
      }
      if (res.skuName != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.app_service.sku.name', res.skuName!)
        ]));
      }
      if (res.skuTier != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.app_service.sku.tier', res.skuTier!)
        ]));
      }
      if (res.instanceId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.app_service.instance.id', res.instanceId!)
        ]));
      }
      if (res.runtimeStack != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'azure.app_service.runtime.stack', res.runtimeStack!)
        ]));
      }
      if (res.runtimeVersion != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'azure.app_service.runtime.version', res.runtimeVersion!)
        ]));
      }
      if (res.operatingSystem != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.app_service.os', res.operatingSystem!)
        ]));
      }
      if (res.deploymentId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'azure.app_service.deployment.id', res.deploymentId!)
        ]));
      }
      if (res.deploymentStatus != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'azure.app_service.deployment.status', res.deploymentStatus!)
        ]));
      }
      if (res.deploymentSource != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
              'azure.app_service.deployment.source', res.deploymentSource!)
        ]));
      }
      if (res.coldStart != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeBool('azure.app_service.cold_start', res.coldStart!)
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('azure.app_service.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400) ||
          res.deploymentStatus == 'Failed' ||
          res.deploymentStatus == 'Cancelled';
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(ErrorResource.errorType.key,
              res.errorCode ?? 'azure_app_service.error')
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
