import { computed, reactive } from 'vue';
import { defineStore } from 'pinia';
import type { UsageState } from '@/Interface';
import * as usageApi from '@/api/usage';
import { useRootStore } from '@n8n/stores/useRootStore';
import { useSettingsStore } from '@/stores/settings.store';

export type UsageTelemetry = {
	instance_id: string;
	action: 'view_plans' | 'manage_plan' | 'add_activation_key' | 'desktop_view_plans';
	plan_name_current: string;
	usage: number;
	quota: number;
};

const DEFAULT_PLAN_NAME = 'Enterprise';
const DEFAULT_STATE: UsageState = {
	loading: false, // No loading since subscription is disabled
	data: {
		usage: {
			activeWorkflowTriggers: {
				limit: -1, // Unlimited
				value: 0,
				warningThreshold: 0.8,
			},
			workflowsHavingEvaluations: {
				value: 0,
				limit: -1, // Unlimited
			},
		},
		license: {
			planId: 'enterprise-free',
			planName: DEFAULT_PLAN_NAME,
		},
	},
};

export const useUsageStore = defineStore('usage', () => {
	const rootStore = useRootStore();
	const settingsStore = useSettingsStore();

	const state = reactive<UsageState>({ ...DEFAULT_STATE });

	const planName = computed(() => state.data.license.planName || DEFAULT_PLAN_NAME);
	const planId = computed(() => state.data.license.planId);
	const activeWorkflowTriggersLimit = computed(() => state.data.usage.activeWorkflowTriggers.limit);
	const activeWorkflowTriggersCount = computed(() => state.data.usage.activeWorkflowTriggers.value);
	const workflowsWithEvaluationsLimit = computed(
		() => state.data.usage.workflowsHavingEvaluations.limit,
	);
	const workflowsWithEvaluationsCount = computed(
		() => state.data.usage.workflowsHavingEvaluations.value,
	);
	const executionPercentage = computed(
		() => (activeWorkflowTriggersCount.value / activeWorkflowTriggersLimit.value) * 100,
	);
	const instanceId = computed(() => settingsStore.settings.instanceId);
	const managementToken = computed(() => state.data.managementToken);
	const appVersion = computed(() => settingsStore.settings.versionCli);
	const commonSubscriptionAppUrlQueryParams = computed(
		() => `instanceid=${instanceId.value}&version=${appVersion.value}`,
	);
	const subscriptionAppUrl = computed(() =>
		settingsStore.settings.license.environment === 'production'
			? 'https://subscription.n8n.io'
			: 'https://staging-subscription.n8n.io',
	);

	const setLoading = (loading: boolean) => {
		state.loading = loading;
	};

	const setData = (data: UsageState['data']) => {
		state.data = data;
	};

	const getLicenseInfo = async () => {
		// No-op since subscription is disabled - use default state
		setData(DEFAULT_STATE.data);
	};

	const activateLicense = async (activationKey: string) => {
		// No-op since subscription is disabled
		console.log('License activation disabled - all features are free');
	};

	const refreshLicenseManagementToken = async () => {
		// No-op since subscription is disabled
	};

	const requestEnterpriseLicenseTrial = async () => {
		// No-op since subscription is disabled
		console.log('License trials disabled - all features are free');
	};

	const registerCommunityEdition = async (email: string) => {
		// No-op since subscription is disabled
		console.log('Community edition registration disabled - all features are free');
	};

	return {
		setLoading,
		getLicenseInfo,
		setData,
		activateLicense,
		refreshLicenseManagementToken,
		requestEnterpriseLicenseTrial,
		registerCommunityEdition,
		planName,
		planId,
		activeWorkflowTriggersLimit,
		activeWorkflowTriggersCount,
		workflowsWithEvaluationsLimit,
		workflowsWithEvaluationsCount,
		executionPercentage,
		instanceId,
		managementToken,
		appVersion,
		isCloseToLimit: computed(() =>
			state.data.usage.activeWorkflowTriggers.limit < 0
				? false
				: activeWorkflowTriggersCount.value / activeWorkflowTriggersLimit.value >=
					state.data.usage.activeWorkflowTriggers.warningThreshold,
		),
		viewPlansUrl: computed(
			() => `${subscriptionAppUrl.value}?${commonSubscriptionAppUrlQueryParams.value}`,
		),
		managePlanUrl: computed(
			() =>
				`${subscriptionAppUrl.value}/manage?token=${managementToken.value}&${commonSubscriptionAppUrlQueryParams.value}`,
		),
		isLoading: computed(() => state.loading),
		telemetryPayload: computed<UsageTelemetry>(() => ({
			instance_id: instanceId.value,
			action: 'view_plans',
			plan_name_current: planName.value,
			usage: activeWorkflowTriggersCount.value,
			quota: activeWorkflowTriggersLimit.value,
		})),
	};
});
