declare function require(name: string): any;

const systemRouter = (() => {
	try {
		return require('@system.router');
	} catch (e) {
		return null;
	}
})();

export default class RouterManager {
	static push(page: string) {
		// 尝试使用系统路由跳转到页面（根据实际项目可调整uri）
		if (systemRouter && systemRouter.push) {
			try {
				const uri = page === 'Index' ? 'pages/Index' : (page === 'Register' ? 'pages/auth/Register' : 'pages/auth/Login');
				systemRouter.push({ uri: uri });
				return;
			} catch (e) {
				console.warn('router push failed', e);
			}
		}
		// 回退：在无法使用系统路由时，打印信息（运行时可替换为其它导航实现）
		console.log('RouterManager.push called for', page);
	}
}
