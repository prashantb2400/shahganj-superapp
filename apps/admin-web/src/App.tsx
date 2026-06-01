import { useState } from 'react';
import { 
  ShieldAlert, 
  LayoutDashboard, 
  UserCheck, 
  Settings, 
  BellRing, 
  LogOut, 
  Database,
  CheckCircle,
  XCircle
} from 'lucide-react';
import Dashboard from './pages/Dashboard';
import { auth, googleProvider } from './firebase';
import { signInWithPopup, signOut, User } from 'firebase/auth';

interface VettingItem {
  id: string;
  name: string;
  category: string;
  phone: string;
  docs: string;
}

export default function App() {
  // Auth state using Firebase User object
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [authError, setAuthError] = useState('');

  // App state
  const [activeTab, setActiveTab] = useState<'dashboard' | 'vetting' | 'campaigns' | 'settings'>('dashboard');
  const [vettedCount, setVettedCount] = useState(84);
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [toastType, setToastType] = useState<'success' | 'info'>('success');

  // Vetting list state
  const [vettingList, setVettingList] = useState<VettingItem[]>([
    { id: '1', name: 'Gupta E-Rickshaw fleet', category: 'Car Rental', phone: '+91 98348 23812', docs: 'Aadhar, Registration Certificate' },
    { id: '2', name: 'Verma Clinic & OPD', category: 'Hospital', phone: '+91 94156 89231', docs: 'OPD License, Identity card' },
    { id: '3', name: 'Shahganj Sweets & Bakery', category: 'Restaurant', phone: '+91 91522 34890', docs: 'FSSAI License, Pan Card' },
  ]);

  // FCM broadcast inputs
  const [broadcastTopic, setBroadcastTopic] = useState('customer');
  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [broadcastBody, setBroadcastBody] = useState('');

  // Fare multipliers inputs
  const [wholeBase, setWholeBase] = useState(20);
  const [wholePerKm, setWholePerKm] = useState(15);
  const [shareBase, setShareBase] = useState(10);
  const [sharePerKm, setSharePerKm] = useState(5);

  const showToast = (msg: string, type: 'success' | 'info' = 'success') => {
    setToastMessage(msg);
    setToastType(type);
    setTimeout(() => setToastMessage(null), 4000);
  };

  const handleGoogleLogin = async () => {
    try {
      const result = await signInWithPopup(auth, googleProvider);
      const loggedUser = result.user;
      
      // Exclusively restrict access to the Superadmin Google account
      const isAllowed = loggedUser.email === 'tradexmeme@gmail.com';

      if (isAllowed) {
        setCurrentUser(loggedUser);
        setAuthError('');
        showToast(`🎉 Authentication successful! Secure console unlocked for ${loggedUser.displayName}.`);
      } else {
        await signOut(auth);
        setAuthError(`Access Denied! ${loggedUser.email} is not a whitelisted operations account.`);
      }
    } catch (err: any) {
      setAuthError(`Sign-in cancelled or failed: ${err.message}`);
    }
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
      setCurrentUser(null);
      showToast('🔌 Operator console securely locked.');
    } catch (err: any) {
      showToast(`Error signing out: ${err.message}`, 'info');
    }
  };

  const handleApprove = (id: string, businessName: string) => {
    setVettingList(prev => prev.filter(item => item.id !== id));
    setVettedCount(prev => prev + 1);
    showToast(`Approved ${businessName}! Firestore document status set to APPROVED.`);
  };

  const handleBroadcast = (e: React.FormEvent) => {
    e.preventDefault();
    if (!broadcastTitle || !broadcastBody) {
      showToast('Please fill out all broadcaster fields!', 'info');
      return;
    }
    showToast(`📡 FCM broadcast sent to segment [fcm_topic: ${broadcastTopic}]! Message Body: ${broadcastBody}`);
    setBroadcastTitle('');
    setBroadcastBody('');
  };

  const handleUpdateFares = (e: React.FormEvent) => {
    e.preventDefault();
    showToast(`💰 Multipliers saved: Whole base ₹${wholeBase}/km, Share base ₹${shareBase}/km synced.`);
  };

  const navigation = [
    { id: 'dashboard', label: 'Overview Dashboard', icon: LayoutDashboard },
    { id: 'vetting', label: `Vetting Queue (${vettingList.length})`, icon: UserCheck },
    { id: 'campaigns', label: 'Broadcast Campaigns', icon: BellRing },
    { id: 'settings', label: 'Financial Setup', icon: Settings },
  ] as const;

  // Render Login Gate (Only Google Sign-In)
  if (!currentUser) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-[#070b19]">
        <div className="absolute inset-0 bg-[#0c1328] opacity-30 bg-[linear-gradient(rgba(255,255,255,0.01)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.01)_1px,transparent_1px)] bg-[size:30px_30px]" />
        
        <div className="relative w-full max-w-md p-8 glass-panel border border-slate-800 rounded-3xl space-y-8 bg-[#0c1226]/80 backdrop-blur-xl">
          <div className="text-center space-y-3">
            <div className="inline-flex p-4 bg-violet-600/10 border border-violet-500/20 rounded-2xl text-violet-400">
              <ShieldAlert className="w-10 h-10" />
            </div>
            <h1 className="text-2xl font-bold text-white tracking-wider">SHAHGANJ OPERATIONS</h1>
            <p className="text-xs text-slate-400 font-semibold tracking-widest uppercase">Super Admin Access Control</p>
          </div>

          {authError && (
            <div className="p-3.5 bg-red-500/10 border border-red-500/20 rounded-xl flex items-center gap-3 text-red-400 text-xs font-semibold">
              <XCircle className="w-4 h-4 shrink-0" />
              <span>{authError}</span>
            </div>
          )}

          <div className="space-y-4">
            <p className="text-slate-400 text-xs text-center leading-relaxed font-semibold">
              To proceed, authenticate using the designated Firebase Superadmin Google account: <span className="text-violet-400">tradexmeme@gmail.com</span>
            </p>

            <button 
              onClick={handleGoogleLogin}
              className="w-full flex items-center justify-center gap-3 py-3.5 bg-white hover:bg-slate-100 text-slate-900 font-bold rounded-xl transition-all duration-200 shadow-lg shadow-white/5"
            >
              {/* Google G logo */}
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path
                  fill="#EA4335"
                  d="M12 5.04c1.66 0 3.2.57 4.38 1.69l3.27-3.27C17.67 1.48 14.99 1 12 1 7.24 1 3.2 3.74 1.15 7.74l3.87 3a7.02 7.02 0 0 1 6.98-5.7z"
                />
                <path
                  fill="#4285F4"
                  d="M23.49 12.27c0-.81-.07-1.59-.2-2.36H12v4.51h6.46a5.52 5.52 0 0 1-2.4 3.62l3.73 2.89c2.18-2.01 3.7-4.97 3.7-8.66z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.02 14.74A6.97 6.97 0 0 1 4.6 12c0-.98.17-1.92.47-2.8l-3.87-3A11.96 11.96 0 0 0 0 12c0 2.22.61 4.29 1.65 6.08l3.37-3.34z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c3.24 0 5.97-1.07 7.96-2.91l-3.73-2.89c-1.03.69-2.35 1.1-4.23 1.1-3.37 0-6.22-2.28-7.24-5.36L.9 16.29C2.9 20.26 6.94 23 12 23z"
                />
              </svg>
              <span>Sign In with Google Account</span>
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex h-screen overflow-hidden bg-[#070b19]">
      
      {/* Toast Alert */}
      {toastMessage && (
        <div className={`fixed bottom-6 right-6 z-50 p-4 rounded-xl border flex items-center gap-3 shadow-xl transition-all duration-300 ${
          toastType === 'success' 
            ? 'bg-emerald-950/90 border-emerald-500/30 text-emerald-400' 
            : 'bg-slate-900/90 border-slate-700 text-slate-300'
        }`}>
          <CheckCircle className="w-5 h-5 shrink-0" />
          <span className="text-sm font-semibold">{toastMessage}</span>
        </div>
      )}

      {/* 1. Sidebar Nav */}
      <aside className="w-64 bg-[#0c1226] border-r border-slate-800 flex flex-col justify-between p-6">
        <div>
          <div className="flex items-center gap-3 mb-8">
            <div className="p-2.5 bg-violet-600/20 border border-violet-500/30 rounded-xl text-violet-400">
              <ShieldAlert className="w-6 h-6" />
            </div>
            <div>
              <h1 className="font-bold text-lg leading-tight tracking-wider text-white">SHAHGANJ</h1>
              <span className="text-xs text-violet-400 font-semibold tracking-widest uppercase">Admin console</span>
            </div>
          </div>

          <nav className="space-y-1.5">
            {navigation.map((item) => {
              const Icon = item.icon;
              const isActive = activeTab === item.id;
              return (
                <button
                  key={item.id}
                  onClick={() => setActiveTab(item.id)}
                  className={`w-full flex items-center gap-3.5 px-4 py-3 rounded-xl transition-all duration-200 text-sm font-medium ${
                    isActive
                      ? 'bg-violet-600 text-white shadow-lg shadow-violet-600/20'
                      : 'text-slate-400 hover:bg-slate-800/40 hover:text-slate-200'
                  }`}
                >
                  <Icon className="w-5 h-5 shrink-0" />
                  <span>{item.label}</span>
                </button>
              );
            })}
          </nav>
        </div>

        {/* User Card */}
        <div className="border-t border-slate-800 pt-5 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {currentUser.photoURL ? (
              <img src={currentUser.photoURL} alt="Avatar" className="w-10 h-10 rounded-full border border-violet-500/20" />
            ) : (
              <div className="w-10 h-10 rounded-full bg-violet-500/10 border border-violet-500/20 flex items-center justify-center font-bold text-violet-400 text-sm">
                {currentUser.displayName?.substring(0, 2).toUpperCase() || 'SA'}
              </div>
            )}
            <div className="leading-tight max-w-[110px]">
              <p className="text-sm font-semibold text-white truncate">{currentUser.displayName || 'Super Admin'}</p>
              <p className="text-xs text-slate-500 truncate">{currentUser.email}</p>
            </div>
          </div>
          <button 
            onClick={handleLogout}
            className="p-2 text-slate-500 hover:text-red-400 transition-colors"
          >
            <LogOut className="w-4.5 h-4.5" />
          </button>
        </div>
      </aside>

      {/* 2. Main Content wrapper */}
      <main className="flex-1 flex flex-col overflow-hidden">
        {/* Top Header */}
        <header className="h-16 border-b border-slate-800/60 bg-[#0c1226]/50 flex items-center justify-between px-8 backdrop-blur-md">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
            <span className="text-xs text-slate-400 font-medium">Asia-South1 Firebase database live</span>
          </div>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-800/30 border border-slate-700/30 text-xs font-semibold text-violet-300">
              <Database className="w-3.5 h-3.5" />
              <span>Version 3.0</span>
            </div>
            <div className="text-xs text-slate-400 font-mono">
              Role: <span className="text-white font-bold">SUPER_ADMIN</span>
            </div>
          </div>
        </header>

        {/* Scrollable View panel */}
        <div className="flex-1 overflow-y-auto p-8 bg-[#070b19]">
          
          {activeTab === 'dashboard' && <Dashboard vettedCount={vettedCount} />}

          {activeTab === 'vetting' && (
            <div className="max-w-6xl mx-auto space-y-6">
              <h2 className="text-2xl font-bold text-white">Merchant Vetting Queue</h2>
              <p className="text-slate-400 -mt-4 text-sm font-sans">Review incoming registrations for restaurant catalogs and local plumbers/electricians.</p>
              
              <div className="glass-panel rounded-2xl p-6 border border-slate-800/80 bg-[#0c1226]/40">
                {vettingList.length === 0 ? (
                  <div className="text-center py-12 space-y-3">
                    <UserCheck className="w-12 h-12 text-slate-600 mx-auto" />
                    <h3 className="font-bold text-white text-lg">All items vetted successfully!</h3>
                    <p className="text-sm text-slate-500">Incoming registration queue is currently empty.</p>
                  </div>
                ) : (
                  <table className="w-full text-left text-sm text-slate-300">
                    <thead className="text-xs text-slate-400 uppercase border-b border-slate-800 bg-slate-900/20">
                      <tr>
                        <th className="px-6 py-4">Business Name</th>
                        <th className="px-6 py-4">Category</th>
                        <th className="px-6 py-4">Phone</th>
                        <th className="px-6 py-4">Documents Provided</th>
                        <th className="px-6 py-4">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800/40">
                      {vettingList.map(item => (
                        <tr key={item.id}>
                          <td className="px-6 py-4 font-semibold text-white">{item.name}</td>
                          <td className="px-6 py-4">
                            <span className="px-2.5 py-1 rounded-full text-xs font-medium bg-cyan-500/10 text-cyan-400">
                              {item.category}
                            </span>
                          </td>
                          <td className="px-6 py-4 font-mono">{item.phone}</td>
                          <td className="px-6 py-4 text-xs text-slate-400">{item.docs}</td>
                          <td className="px-6 py-4">
                            <button 
                              onClick={() => handleApprove(item.id, item.name)}
                              className="px-3.5 py-1.5 rounded-lg bg-violet-600 text-white font-semibold hover:bg-violet-500 text-xs transition-colors shadow-sm"
                            >
                              Approve Account
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )}
              </div>
            </div>
          )}

          {activeTab === 'campaigns' && (
            <div className="max-w-3xl mx-auto space-y-6">
              <h2 className="text-2xl font-bold text-white">FCM Push Broadcaster</h2>
              <p className="text-slate-400 -mt-4 text-sm font-sans">Send segmented cloud messages directly to active customers, merchants, or riders.</p>

              <form onSubmit={handleBroadcast} className="glass-panel rounded-2xl p-6 border border-slate-800/80 bg-[#0c1226]/40 space-y-5">
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Target Segment</label>
                  <select 
                    value={broadcastTopic}
                    onChange={(e) => setBroadcastTopic(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm focus:border-violet-500 outline-none"
                  >
                    <option value="customer">All Active Customers (fcm_topic: customer)</option>
                    <option value="merchant">Registered Food Merchants (fcm_topic: merchant)</option>
                    <option value="rider">Active E-Rickshaw Drivers (fcm_topic: rider)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Notification Title</label>
                  <input 
                    type="text" 
                    placeholder="e.g. UPI-first rides starting today!" 
                    value={broadcastTitle}
                    onChange={(e) => setBroadcastTitle(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm focus:border-violet-500 outline-none"
                    required
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Message Body</label>
                  <textarea 
                    rows={3} 
                    placeholder="Type push message details..." 
                    value={broadcastBody}
                    onChange={(e) => setBroadcastBody(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm focus:border-violet-500 outline-none"
                    required
                  />
                </div>

                <button 
                  type="submit"
                  className="w-full py-3.5 rounded-xl bg-violet-600 text-white font-bold hover:bg-violet-500 transition-all duration-200"
                >
                  Broadcast via Cloud Functions
                </button>
              </form>
            </div>
          )}

          {activeTab === 'settings' && (
            <div className="max-w-3xl mx-auto space-y-6">
              <h2 className="text-2xl font-bold text-white">Global Fare Multipliers</h2>
              <p className="text-slate-400 -mt-4 text-sm font-sans">Configure billing constants for OSRM e-rickshaw callout algorithms.</p>

              <form onSubmit={handleUpdateFares} className="glass-panel rounded-2xl p-6 border border-slate-800/80 bg-[#0c1226]/40 space-y-5">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Whole E-Rickshaw Base (₹)</label>
                    <input 
                      type="number" 
                      value={wholeBase}
                      onChange={(e) => setWholeBase(Number(e.target.value))}
                      className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" 
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Whole E-Rickshaw Per Km (₹)</label>
                    <input 
                      type="number" 
                      value={wholePerKm}
                      onChange={(e) => setWholePerKm(Number(e.target.value))}
                      className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" 
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 border-t border-slate-800/60 pt-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Shared Seat Base (₹)</label>
                    <input 
                      type="number" 
                      value={shareBase}
                      onChange={(e) => setShareBase(Number(e.target.value))}
                      className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" 
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Shared Seat Per Km (₹)</label>
                    <input 
                      type="number" 
                      value={sharePerKm}
                      onChange={(e) => setSharePerKm(Number(e.target.value))}
                      className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" 
                    />
                  </div>
                </div>

                <button 
                  type="submit"
                  className="w-full py-3.5 rounded-xl bg-violet-600 text-white font-bold hover:bg-violet-500 transition-all duration-200"
                >
                  Update Constants in Firestore
                </button>
              </form>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

