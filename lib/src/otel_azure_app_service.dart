// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_azure_app_service_suppression.dart';

class AzureAppServiceResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AzureAppServiceCallResult<T> {
  /// Creates a call result.
  const AzureAppServiceCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AzureAppServiceResult? result;
}

Future<T> tracedAzureAppService<T>({
  required String operation,
  required Future<AzureAppServiceCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (azureAppServiceInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTelAPI.tracerProvider().getTracer('otel_azure_app_service');
  final span =
      t.startSpan('azure_app_service $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'azure')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.service', 'AppService')]));
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.method', operation)]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.subscriptionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.subscription.id', res.subscriptionId!)
        ]));
      }
      if (res.resourceGroup != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.resource_group', res.resourceGroup!)
        ]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('azure.region', res.region!)]));
      }
      if (res.siteName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.app_service.site.name', res.siteName!)
        ]));
      }
      if (res.slotName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.app_service.slot', res.slotName!)
        ]));
      }
      if (res.appServicePlan != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.plan.name', res.appServicePlan!)
        ]));
      }
      if (res.skuName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.app_service.sku.name', res.skuName!)
        ]));
      }
      if (res.skuTier != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.app_service.sku.tier', res.skuTier!)
        ]));
      }
      if (res.instanceId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.instance.id', res.instanceId!)
        ]));
      }
      if (res.runtimeStack != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.runtime.stack', res.runtimeStack!)
        ]));
      }
      if (res.runtimeVersion != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.runtime.version', res.runtimeVersion!)
        ]));
      }
      if (res.operatingSystem != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.app_service.os', res.operatingSystem!)
        ]));
      }
      if (res.deploymentId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.deployment.id', res.deploymentId!)
        ]));
      }
      if (res.deploymentStatus != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.deployment.status', res.deploymentStatus!)
        ]));
      }
      if (res.deploymentSource != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.deployment.source', res.deploymentSource!)
        ]));
      }
      if (res.coldStart != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeBool('azure.app_service.cold_start', res.coldStart!)
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'azure.app_service.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400) ||
          res.deploymentStatus == 'Failed' ||
          res.deploymentStatus == 'Cancelled';
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(ErrorAttributes.errorType.key,
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
