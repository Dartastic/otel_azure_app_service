// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_azure_app_service/otel_azure_app_service.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_azure_app_service-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('sites.get records sku + runtime', () async {
    await tracedAzureAppService<String>(
      operation: 'sites.get',
      invoke: () async => const AzureAppServiceCallResult(
        value: 'ok',
        result: AzureAppServiceResult(
          siteName: 'webapp',
          skuName: 'P1v3',
          skuTier: 'PremiumV3',
          runtimeStack: 'DOTNETCORE',
          runtimeVersion: '8.0',
          operatingSystem: 'Linux',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_app_service sites.get')!);
    expect(a['azure.app_service.sku.tier'], 'PremiumV3');
    expect(a['azure.app_service.runtime.stack'], 'DOTNETCORE');
    expect(a['azure.app_service.os'], 'Linux');
  });

  test('Failed deployment sets span error', () async {
    await tracedAzureAppService<String>(
      operation: 'deployments.get',
      invoke: () async => const AzureAppServiceCallResult(
        value: 'ok',
        result: AzureAppServiceResult(
          siteName: 'webapp',
          deploymentStatus: 'Failed',
          deploymentSource: 'GitHub',
        ),
      ),
    );
    expect(
      spans.findSpanByName('azure_app_service deployments.get')!.status,
      SpanStatusCode.Error,
    );
  });

  test('slots.swap records slot + cold start', () async {
    await tracedAzureAppService<String>(
      operation: 'slots.swap',
      invoke: () async => const AzureAppServiceCallResult(
        value: 'ok',
        result: AzureAppServiceResult(
          siteName: 'webapp',
          slotName: 'staging',
          coldStart: true,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_app_service slots.swap')!);
    expect(a['azure.app_service.slot'], 'staging');
    expect(a['azure.app_service.cold_start'], true);
  });

  test('suppression skips spans', () async {
    await runWithoutAzureAppServiceInstrumentationAsync(() async {
      await tracedAzureAppService<String>(
        operation: 'sites.list',
        invoke: () async => const AzureAppServiceCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('azure_app_service '), isEmpty);
  });
}
