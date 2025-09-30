import { computed, reactive, ref } from 'vue';
import { defineStore } from 'pinia';
import type { CloudPlanState } from '@/Interface';
import { useRootStore } from '@n8n/stores/useRootStore';
import { useSettingsStore } from '@/stores/settings.store';
import type { Cloud } from '@n8n/rest-api-client/api/cloudPlans';
import { STORES } from '@n8n/stores';
import { hasPermission } from '@/utils/rbac/permissions';

const DEFAULT_STATE: CloudPlanState = {
	initialized: true, // Always initialized since subscription is disabled
	data: null,
	usage: null,
	loadingPlan: false,
};

export const useCloudPlanStore = defineStore(STORES.CLOUD_PLAN, () => {
	const rootStore = useRootStore();
	const settingsStore = useSettingsStore();

	const state = reactive<CloudPlanState>(DEFAULT_STATE);
	const currentUserCloudInfo = ref<Cloud.UserAccount | null>(null);

	const reset = () => {
		currentUserCloudInfo.value = null;
		state.data = null;
		state.usage = null;
	};

	const userIsTrialing = computed(() => false); // No trials since subscription is disabled

	const currentPlanData = computed(() => null); // No plan data since subscription is disabled

	const currentUsageData = computed(() => null); // No usage data since subscription is disabled

	const selectedApps = computed(() => currentUserCloudInfo.value?.selectedApps);
	const codingSkill = computed(() => {
		const information = currentUserCloudInfo.value?.information;
		if (!information) {
			return 0;
		}

		if (
			!(
				'which_of_these_do_you_feel_comfortable_doing' in information &&
				information.which_of_these_do_you_feel_comfortable_doing &&
				Array.isArray(information.which_of_these_do_you_feel_comfortable_doing)
			)
		) {
			return 0;
		}

		return information.which_of_these_do_you_feel_comfortable_doing.length;
	});

	const trialExpired = computed(() => false); // No trials since subscription is disabled

	const allExecutionsUsed = computed(() => false); // No limits since subscription is disabled

	const hasCloudPlan = computed<boolean>(() => false); // No cloud plans since subscription is disabled

	const getUserCloudAccount = async () => {
		// No-op since subscription is disabled
		return null;
	};

	const getAutoLoginCode = async (): Promise<{ code: string }> => {
		// No-op since subscription is disabled
		return { code: '' };
	};

	const getOwnerCurrentPlan = async () => {
		// No-op since subscription is disabled
		return null;
	};

	const getInstanceCurrentUsage = async () => {
		// No-op since subscription is disabled
		return null;
	};

	const usageLeft = computed(() => {
		// Unlimited usage since subscription is disabled
		return { workflowsLeft: -1, executionsLeft: -1 };
	});

	const trialDaysLeft = computed(() => {
		// No trials since subscription is disabled
		return -1;

	});

	const startPollingInstanceUsageData = () => {
		// No-op since subscription is disabled
	};

	const checkForCloudPlanData = async (): Promise<void> => {
		// No-op since subscription is disabled
	};

	const fetchUserCloudAccount = async () => {
		// No-op since subscription is disabled
	};

	const initialize = async () => {
		// Always initialized since subscription is disabled
		state.initialized = true;

	};

	const generateCloudDashboardAutoLoginLink = async (data: { redirectionPath: string }) => {
		// No-op since subscription is disabled
		return '';
	};

	return {
		state,
		usageLeft,
		trialDaysLeft,
		userIsTrialing,
		currentPlanData,
		currentUsageData,
		trialExpired,
		allExecutionsUsed,
		hasCloudPlan,
		currentUserCloudInfo,
		generateCloudDashboardAutoLoginLink,
		initialize,
		getOwnerCurrentPlan,
		getInstanceCurrentUsage,
		reset,
		checkForCloudPlanData,
		fetchUserCloudAccount,
		getAutoLoginCode,
		selectedApps,
		codingSkill,
	};
});
