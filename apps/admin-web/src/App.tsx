import { useState } from 'react';
import { 
  ShieldAlert, 
  LayoutDashboard, 
  UserCheck, 
  Settings, 
  BellRing, 
  LogOut, 
  Database
} from 'lucide-react';
import Dashboard from './pages/Dashboard';

export default function App() {
  const [activeTab, setActiveTab] = useState<'dashboard' | 'vetting' | 'campaigns' | 'settings'>('dashboard');

  const navigation = [
    { id: 'dashboard', label: 'Overview Dashboard', icon: LayoutDashboard },
    { id: 'vetting', label: 'Listings Vetting Queue', icon: UserCheck },
    { id: 'campaigns', label: 'Broadcast Campaigns', icon: BellRing },
    { id: 'settings', label: 'Financial Setup', icon: Settings },
  ] as const;

  return (
    <div className="flex h-screen overflow-hidden bg-[#070b19]">
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
            <div className="w-10 h-10 rounded-full bg-violet-500/10 border border-violet-500/20 flex items-center justify-center font-bold text-violet-400 text-sm">
              SA
            </div>
            <div className="leading-tight">
              <p className="text-sm font-semibold text-white">Super Admin</p>
              <p className="text-xs text-slate-500">ops@shahganj.online</p>
            </div>
          </div>
          <button className="p-2 text-slate-500 hover:text-red-400 transition-colors">
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
            <div className="text-xs text-slate-400">
              Session time: <span className="font-mono text-slate-200">22:20 PM</span>
            </div>
          </div>
        </header>

        {/* Scrollable View panel */}
        <div className="flex-1 overflow-y-auto p-8 bg-[#070b19]">
          {activeTab === 'dashboard' && <Dashboard />}

          {activeTab === 'vetting' && (
            <div className="max-w-6xl mx-auto space-y-6">
              <h2 className="text-2xl font-bold text-white">Merchant Vetting Queue</h2>
              <p className="text-slate-400 -mt-4 text-sm">Review incoming registrations for restaurant catalogs and local plumbers/electricians.</p>
              
              <div className="glass-panel rounded-2xl p-6 border border-slate-800">
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
                    <tr>
                      <td className="px-6 py-4 font-semibold text-white">Gupta E-Rickshaw fleet</td>
                      <td className="px-6 py-4"><span className="px-2.5 py-1 rounded-full text-xs font-medium bg-cyan-500/10 text-cyan-400">Car Rental</span></td>
                      <td className="px-6 py-4 font-mono">+91 98348 23812</td>
                      <td className="px-6 py-4 text-xs text-slate-400">Aadhar, Registration Certificate</td>
                      <td className="px-6 py-4">
                        <button className="px-3 py-1.5 rounded-lg bg-violet-600 text-white font-semibold hover:bg-violet-500 text-xs transition-colors">Approve Account</button>
                      </td>
                    </tr>
                    <tr>
                      <td className="px-6 py-4 font-semibold text-white">Verma Clinic & OPD</td>
                      <td className="px-6 py-4"><span className="px-2.5 py-1 rounded-full text-xs font-medium bg-red-500/10 text-red-400">Hospital</span></td>
                      <td className="px-6 py-4 font-mono">+91 94156 89231</td>
                      <td className="px-6 py-4 text-xs text-slate-400">OPD License, Identity card</td>
                      <td className="px-6 py-4">
                        <button className="px-3 py-1.5 rounded-lg bg-violet-600 text-white font-semibold hover:bg-violet-500 text-xs transition-colors">Approve Account</button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'campaigns' && (
            <div className="max-w-3xl mx-auto space-y-6">
              <h2 className="text-2xl font-bold text-white">FCM Push Broadcaster</h2>
              <p className="text-slate-400 -mt-4 text-sm">Send segmented cloud messages directly to active customers, merchants, or riders.</p>

              <div className="glass-panel rounded-2xl p-6 border border-slate-800 space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Target Segment</label>
                  <select className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm focus:border-violet-500 outline-none">
                    <option>All Active Customers (fcm_topic: customer)</option>
                    <option>Registered Food Merchants (fcm_topic: merchant)</option>
                    <option>Active E-Rickshaw Drivers (fcm_topic: rider)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Notification Title</label>
                  <input type="text" placeholder="e.g. UPI-first rides starting today!" className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm focus:border-violet-500 outline-none" />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Message Body</label>
                  <textarea rows={3} placeholder="Type push message details..." className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm focus:border-violet-500 outline-none" />
                </div>

                <button className="w-full py-3 rounded-xl bg-violet-600 text-white font-bold hover:bg-violet-500 transition-all duration-200">
                  Broadcast via Cloud Functions
                </button>
              </div>
            </div>
          )}

          {activeTab === 'settings' && (
            <div className="max-w-3xl mx-auto space-y-6">
              <h2 className="text-2xl font-bold text-white">Global Fare Multipliers</h2>
              <p className="text-slate-400 -mt-4 text-sm">Configure billing constants for OSRM e-rickshaw callout algorithms.</p>

              <div className="glass-panel rounded-2xl p-6 border border-slate-800 space-y-5">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Whole E-Rickshaw Base (₹)</label>
                    <input type="number" defaultValue={20} className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Whole E-Rickshaw Per Km (₹)</label>
                    <input type="number" defaultValue={15} className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 border-t border-slate-800/60 pt-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Shared Seat Base (₹)</label>
                    <input type="number" defaultValue={10} className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-wider mb-2">Shared Seat Per Km (₹)</label>
                    <input type="number" defaultValue={5} className="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-slate-300 text-sm font-semibold outline-none" />
                  </div>
                </div>

                <button className="w-full py-3 rounded-xl bg-violet-600 text-white font-bold hover:bg-violet-500 transition-all duration-200">
                  Update Constants in Firestore
                </button>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
